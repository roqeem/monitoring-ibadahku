/* eslint-disable @typescript-eslint/no-var-requires */
import * as admin from 'firebase-admin';
import { onRequest } from 'firebase-functions/v2/https';

// Lazy initialization to support unit testing without auto-connecting
let _app: admin.app.App | undefined;

export function getApp(): admin.app.App {
  if (!_app) {
    _app = admin.initializeApp();
  }
  return _app;
}

// Health endpoint for sanity checking deployment
export const health = onRequest(
  { region: 'asia-southeast2' },
  (_req, res) => {
    res.json({ status: 'ok' });
  }
);

// Exported for testability
export const ready = true;
