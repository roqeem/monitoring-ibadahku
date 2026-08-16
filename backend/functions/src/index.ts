/* eslint-disable @typescript-eslint/no-var-requires */
import { initializeApp, getApps, App } from 'firebase-admin/app';
import { getFirestore, Firestore } from 'firebase-admin/firestore';

// Lazy initialization to support offline testing
let _app: App | undefined;

export function getApp(): App {
  if (!_app) {
    if (getApps().length === 0) {
      _app = initializeApp();
    } else {
      _app = getApps()[0];
    }
  }
  return _app;
}

// Initialize Firestore lazily
export function getDb(): Firestore {
  getApp(); // Ensure app is initialized
  return getFirestore();
}

import { createInvitation } from './invitations.js';
import { acceptInvitation, revokeAccess, stopMonitoring, onUserDeletedTrigger } from './relationships.js';
import { sendStandardReminder } from './reminders.js';
import { getFamilyDigest } from './digest.js';

export {
  createInvitation,
  acceptInvitation,
  revokeAccess,
  stopMonitoring,
  onUserDeletedTrigger,
  sendStandardReminder,
  getFamilyDigest,
};

// Health endpoint
import { onRequest } from 'firebase-functions/v2/https';

export const health = onRequest(
  { region: 'asia-southeast2' },
  (_req, res) => {
    res.json({ status: 'ok' });
  }
);

export const ready = true;