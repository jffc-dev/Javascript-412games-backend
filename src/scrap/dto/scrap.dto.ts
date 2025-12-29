import {
  IsString,
  IsUrl,
  IsNotEmpty,
  IsEnum,
  IsOptional,
} from 'class-validator';

export enum ScrapType {
  PLAYER = 'player',
  TEAM = 'team',
  LEAGUE = 'league',
  MANAGER = 'manager',
}

export class ScrapUrlDto {
  @IsUrl({}, { message: 'Please provide a valid URL' })
  @IsNotEmpty({ message: 'URL is required' })
  url: string;

  @IsEnum(ScrapType, { message: 'Invalid scrap type' })
  @IsNotEmpty({ message: 'Scrap type is required' })
  type: ScrapType;

  @IsOptional()
  @IsString()
  notes?: string;
}

export class ScrapPlayerResultDto {
  name: string;
  fullName?: string;
  dateOfBirth?: string;
  nationality?: string;
  nationalities?: string[];
  position?: string;
  foot?: string;
  heightCm?: number;
  currentTeam?: string;
  currentTeamId?: string;
  marketValueEuros?: number;
  imageUrl?: string;
  transfermarktId?: string;
  careerHistory?: CareerEntryDto[];
}

export class CareerEntryDto {
  teamName: string;
  teamId?: string;
  leagueName?: string;
  leagueId?: string;
  seasonStart: number;
  seasonEnd?: number;
  appearances?: number;
  goals?: number;
  assists?: number;
  isLoan?: boolean;
  isCurrent?: boolean;
}

export class ScrapTeamResultDto {
  name: string;
  shortName?: string;
  country?: string;
  foundedYear?: number;
  stadium?: string;
  logoUrl?: string;
  transfermarktId?: string;
  leagueName?: string;
  leagueId?: string;
  squad?: SquadMemberDto[];
  trophies?: TrophyDto[];
}

export class SquadMemberDto {
  name: string;
  personId?: string;
  position?: string;
  nationality?: string;
  number?: number;
}

export class TrophyDto {
  competitionName: string;
  season: number;
  competitionType?: string;
}

export class ScrapResponseDto<T> {
  success: boolean;
  data?: T;
  error?: string;
  scrapedAt: Date;
  sourceUrl: string;
}
