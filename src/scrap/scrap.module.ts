import { Module } from '@nestjs/common';
import { ScrapController } from './scrap.controller';
import { ScrapService } from './scrap.service';

@Module({
  controllers: [ScrapController],
  providers: [ScrapService],
  exports: [ScrapService],
})
export class ScrapModule {}
