/* eslint-disable @typescript-eslint/no-var-requires */
import * as admin from 'firebase-admin';

// Lazy initialization to support offline testing
let _app: admin.app.App | undefined;

export function getApp(): admin.app.App {
  if (!_app) {
    _app = admin.initializeApp();
  }
  return _app;
}

import { createInvitation } from './invitations';
import { acceptInvitation, revokeAccess, stopMonitoring, onUserDeletedTrigger } from './relationships';
import { sendStandardReminder } from './reminders';
import { getFamilyDigest } from './digest';

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
