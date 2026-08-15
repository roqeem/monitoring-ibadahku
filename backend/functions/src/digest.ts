import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore, Timestamp, Firestore } from 'firebase-admin/firestore';
import {
  Relationship,
  RelationshipStatus,
  ChildSummary,
  relationshipsPath,
} from './schema.js';

let db: Firestore;
function getDb(): Firestore {
  if (!db) {
    if (getApps().length === 0) initializeApp();
    db = getFirestore();
  }
  return db;
}

export interface DigestRequest {
  date: string; // YYYY-MM-DD UTC
}

/**
 * Returns a family digest of worship snapshots for a given date,
 * including only children with an active relationship.
 * Worship data is read-only — this function never writes worship data.
 */
export const getFamilyDigest = onCall<DigestRequest>(
  { region: 'asia-southeast2', secrets: [] },
  async (request) => {
    const authUser = request.auth;
    if (!authUser) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }
    const guardianId = authUser.uid;
    const { date } = request.data as DigestRequest;

    // Rate limit: 1 call/min per caller
    // (checked via lightweight in-memory window in production; here we just proceed)

    const rels = await db
      .collection('relationships')
      .where('guardianId', '==', guardianId)
      .where('status', '==', RelationshipStatus.Active)
      .get();

    const summaries: ChildSummary[] = [];

    for (const doc of rels.docs) {
      const rel = doc.data() as Relationship;
      const childId = rel.childId;

      // Read child profile (name, photo)
      const childSnap = await getDb().doc(`children/${childId}`).get();
      const childData = childSnap.exists ? childSnap.data() : null;

      // Read worship records for date
      // Worship records live in the IbadahKu schema: daily_records/{childId}_{date}
      const recordId = `${childId}_${date}`;
      const recordSnap = await getDb().doc(`daily_records/${recordId}`).get();

      let completed = 0;
      let pending = 0;
      let skipped = 0;

      if (recordSnap.exists) {
        const data = recordSnap.data() as {
          prayers?: Record<string, { status?: string }>;
          sunnah?: Record<string, { completed?: boolean }>;
          dhikr?: Record<string, { completed?: boolean }>;
          doa?: Record<string, { completed?: boolean }>;
        };

        const countStatus = (obj: Record<string, { status?: string }> | undefined) => {
          if (!obj) return;
          Object.values(obj).forEach((entry) => {
            if (entry.status === 'Terlewat' || entry.status === 'Terlewat') {
              skipped++;
            } else if (entry.status && entry.status !== 'Belum dikerjakan') {
              completed++;
            } else {
              pending++;
            }
          });
        };

        const countBool = (obj: Record<string, { completed?: boolean }> | undefined) => {
          if (!obj) return;
          Object.values(obj).forEach((entry) => {
            if (entry.completed) completed++;
            else pending++;
          });
        };

        countStatus(data.prayers);
        countBool(data.sunnah);
        countBool(data.dhikr);
        countBool(data.doa);
      } else {
        pending = 0; // no record = nothing recorded
      }

      summaries.push({
        childId,
        displayName: childData?.displayName ?? null,
        photoUrl: childData?.photoUrl ?? null,
        worshipDate: date,
        completed,
        pending,
        skipped,
        lastUpdated: (recordSnap.updateTime ?? childSnap.updateTime ?? null) as Timestamp,
      });
    }

    return { children: summaries };
  }
);