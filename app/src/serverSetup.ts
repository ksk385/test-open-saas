import logger from 'morgan';
import { type MiddlewareConfigFn } from 'wasp/server';

export const serverMiddlewareFn: MiddlewareConfigFn = (middlewareConfig) => {
  // Example of adding an extra domains to CORS.
  middlewareConfig.set('logger', logger('combined'));
  return middlewareConfig;
};
