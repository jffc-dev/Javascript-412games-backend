import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { GameModule } from './game/game.module';
import { ScrapModule } from './scrap/scrap.module';

@Module({
  imports: [GameModule, ScrapModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
