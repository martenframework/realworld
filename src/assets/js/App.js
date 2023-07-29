/* eslint-env browser */

import controllers from './controllers/index.js';
import DOMRouter from './core/DOMRouter.js';

const router = new DOMRouter(controllers);

document.addEventListener('DOMContentLoaded', () => {
  // Initializes the DOM router. The DOM router is used to execute specific portions of JS code for
  // each specific page.
  router.init();
});
