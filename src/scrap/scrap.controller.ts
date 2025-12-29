import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  BadRequestException,
} from '@nestjs/common';
import { ScrapService } from './scrap.service';
import { ScrapUrlDto, ScrapType } from './dto';

@Controller('scrap')
export class ScrapController {
  constructor(private readonly scrapService: ScrapService) {}

  @Post('player')
  @HttpCode(HttpStatus.OK)
  async scrapePlayer(@Body() dto: ScrapUrlDto) {
    if (dto.type !== ScrapType.PLAYER) {
      throw new BadRequestException('Invalid scrap type for player endpoint');
    }

    // Validate URL format (optional - can be strict about Transfermarkt URLs)
    if (
      !this.scrapService.validateTransfermarktUrl(dto.url, ScrapType.PLAYER)
    ) {
      // For now, just log a warning but allow any URL for flexibility
      console.warn('URL may not be a valid Transfermarkt player URL:', dto.url);
    }

    return this.scrapService.scrapePlayer(dto.url);
  }

  @Post('team')
  @HttpCode(HttpStatus.OK)
  async scrapeTeam(@Body() dto: ScrapUrlDto) {
    if (dto.type !== ScrapType.TEAM) {
      throw new BadRequestException('Invalid scrap type for team endpoint');
    }

    // Validate URL format (optional)
    if (!this.scrapService.validateTransfermarktUrl(dto.url, ScrapType.TEAM)) {
      console.warn('URL may not be a valid Transfermarkt team URL:', dto.url);
    }

    return this.scrapService.scrapeTeam(dto.url);
  }

  @Post()
  @HttpCode(HttpStatus.OK)
  async scrape(@Body() dto: ScrapUrlDto) {
    switch (dto.type) {
      case ScrapType.PLAYER:
        return this.scrapService.scrapePlayer(dto.url);
      case ScrapType.TEAM:
        return this.scrapService.scrapeTeam(dto.url);
      case ScrapType.LEAGUE:
      case ScrapType.MANAGER:
        throw new BadRequestException(
          `Scrap type '${dto.type}' is not yet implemented`,
        );
      default:
        throw new BadRequestException('Invalid scrap type');
    }
  }
}
