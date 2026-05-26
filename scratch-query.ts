import { PGLiteEngine } from './src/core/pglite-engine.ts';

const engine = new PGLiteEngine();
await engine.connect({ database_path: 'C:\\Users\\giftlaya\\.gbrain\\brain.pglite' });

const linkCount = await engine.executeRaw(`SELECT COUNT(*) FROM links`);
console.log('Links count in DB:', linkCount);

const pagesCount = await engine.executeRaw(`SELECT COUNT(*) FROM pages`);
console.log('Pages count in DB:', pagesCount);

const timelineCount = await engine.executeRaw(`SELECT COUNT(*) FROM timeline_entries`);
console.log('Timeline entries count in DB:', timelineCount);

await engine.disconnect();
