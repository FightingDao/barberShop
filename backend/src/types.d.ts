declare module 'koa-bodyparser' {
  import { Middleware } from 'koa'
  function bodyParser(options?: any): Middleware
  export = bodyParser
}
