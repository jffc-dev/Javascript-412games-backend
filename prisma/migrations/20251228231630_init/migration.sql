-- CreateTable
CREATE TABLE "leagues" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "country" VARCHAR(100),
    "tier" INTEGER,
    "competition_type" VARCHAR(50),
    "transfermarkt_id" VARCHAR(50),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "leagues_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "teams" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "short_name" VARCHAR(100),
    "league_id" INTEGER,
    "country" VARCHAR(100),
    "founded_year" INTEGER,
    "transfermarkt_id" VARCHAR(50),
    "logo_url" TEXT,
    "stadium" VARCHAR(255),
    "has_won_champions_league" BOOLEAN NOT NULL DEFAULT false,
    "has_won_europa_league" BOOLEAN NOT NULL DEFAULT false,
    "has_won_domestic_league" BOOLEAN NOT NULL DEFAULT false,
    "champions_league_titles" INTEGER NOT NULL DEFAULT 0,
    "europa_league_titles" INTEGER NOT NULL DEFAULT 0,
    "domestic_league_titles" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "teams_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "persons" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "full_name" VARCHAR(255),
    "date_of_birth" DATE,
    "nationality" VARCHAR(100),
    "transfermarkt_id" VARCHAR(50),
    "image_url" TEXT,
    "is_player" BOOLEAN NOT NULL DEFAULT false,
    "is_manager" BOOLEAN NOT NULL DEFAULT false,
    "is_retired_player" BOOLEAN NOT NULL DEFAULT false,
    "additional_data" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "persons_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "player_profiles" (
    "person_id" INTEGER NOT NULL,
    "position" VARCHAR(50),
    "foot" VARCHAR(20),
    "height_cm" INTEGER,
    "current_team_id" INTEGER,
    "market_value_euros" BIGINT,
    "has_won_champions_league" BOOLEAN NOT NULL DEFAULT false,
    "has_won_world_cup" BOOLEAN NOT NULL DEFAULT false,
    "has_won_ballon_dor" BOOLEAN NOT NULL DEFAULT false,
    "career_clubs_ids" INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    "career_leagues_ids" INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "player_profiles_pkey" PRIMARY KEY ("person_id")
);

-- CreateTable
CREATE TABLE "manager_profiles" (
    "person_id" INTEGER NOT NULL,
    "current_team_id" INTEGER,
    "preferred_formation" VARCHAR(20),
    "coaching_license" VARCHAR(100),
    "has_won_champions_league_as_manager" BOOLEAN NOT NULL DEFAULT false,
    "has_won_domestic_league_as_manager" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "manager_profiles_pkey" PRIMARY KEY ("person_id")
);

-- CreateTable
CREATE TABLE "player_career" (
    "id" SERIAL NOT NULL,
    "person_id" INTEGER NOT NULL,
    "team_id" INTEGER NOT NULL,
    "league_id" INTEGER,
    "season_start" INTEGER NOT NULL,
    "season_end" INTEGER,
    "appearances" INTEGER,
    "goals" INTEGER,
    "assists" INTEGER,
    "is_loan" BOOLEAN NOT NULL DEFAULT false,
    "is_current" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "player_career_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "manager_career" (
    "id" SERIAL NOT NULL,
    "person_id" INTEGER NOT NULL,
    "team_id" INTEGER NOT NULL,
    "league_id" INTEGER,
    "appointment_date" DATE NOT NULL,
    "departure_date" DATE,
    "games_managed" INTEGER,
    "wins" INTEGER,
    "draws" INTEGER,
    "losses" INTEGER,
    "is_current" BOOLEAN NOT NULL DEFAULT false,
    "dismissal_reason" VARCHAR(100),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "manager_career_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "competitions" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "short_name" VARCHAR(100),
    "competition_type" VARCHAR(100),
    "tier" VARCHAR(50),
    "region" VARCHAR(100),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "competitions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "team_trophies" (
    "id" SERIAL NOT NULL,
    "team_id" INTEGER NOT NULL,
    "competition_id" INTEGER NOT NULL,
    "season" INTEGER NOT NULL,
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "team_trophies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "player_trophies" (
    "id" SERIAL NOT NULL,
    "person_id" INTEGER NOT NULL,
    "competition_id" INTEGER NOT NULL,
    "team_id" INTEGER,
    "season" INTEGER NOT NULL,
    "is_national_team" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "player_trophies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "manager_trophies" (
    "id" SERIAL NOT NULL,
    "person_id" INTEGER NOT NULL,
    "competition_id" INTEGER NOT NULL,
    "team_id" INTEGER,
    "season" INTEGER NOT NULL,
    "is_national_team" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "manager_trophies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "person_nationalities" (
    "person_id" INTEGER NOT NULL,
    "nationality" VARCHAR(100) NOT NULL,

    CONSTRAINT "person_nationalities_pkey" PRIMARY KEY ("person_id","nationality")
);

-- CreateIndex
CREATE UNIQUE INDEX "leagues_transfermarkt_id_key" ON "leagues"("transfermarkt_id");

-- CreateIndex
CREATE UNIQUE INDEX "teams_transfermarkt_id_key" ON "teams"("transfermarkt_id");

-- CreateIndex
CREATE INDEX "teams_league_id_idx" ON "teams"("league_id");

-- CreateIndex
CREATE INDEX "teams_name_idx" ON "teams"("name");

-- CreateIndex
CREATE INDEX "teams_has_won_champions_league_idx" ON "teams"("has_won_champions_league");

-- CreateIndex
CREATE UNIQUE INDEX "persons_transfermarkt_id_key" ON "persons"("transfermarkt_id");

-- CreateIndex
CREATE INDEX "persons_nationality_idx" ON "persons"("nationality");

-- CreateIndex
CREATE INDEX "persons_is_player_is_manager_idx" ON "persons"("is_player", "is_manager");

-- CreateIndex
CREATE INDEX "player_profiles_current_team_id_idx" ON "player_profiles"("current_team_id");

-- CreateIndex
CREATE INDEX "player_profiles_has_won_champions_league_idx" ON "player_profiles"("has_won_champions_league");

-- CreateIndex
CREATE INDEX "manager_profiles_current_team_id_idx" ON "manager_profiles"("current_team_id");

-- CreateIndex
CREATE INDEX "manager_profiles_has_won_champions_league_as_manager_idx" ON "manager_profiles"("has_won_champions_league_as_manager");

-- CreateIndex
CREATE INDEX "player_career_person_id_team_id_idx" ON "player_career"("person_id", "team_id");

-- CreateIndex
CREATE INDEX "player_career_season_start_season_end_idx" ON "player_career"("season_start", "season_end");

-- CreateIndex
CREATE INDEX "player_career_is_current_idx" ON "player_career"("is_current");

-- CreateIndex
CREATE INDEX "manager_career_person_id_team_id_idx" ON "manager_career"("person_id", "team_id");

-- CreateIndex
CREATE INDEX "manager_career_is_current_idx" ON "manager_career"("is_current");

-- CreateIndex
CREATE UNIQUE INDEX "competitions_name_key" ON "competitions"("name");

-- CreateIndex
CREATE INDEX "team_trophies_team_id_competition_id_idx" ON "team_trophies"("team_id", "competition_id");

-- CreateIndex
CREATE INDEX "team_trophies_season_idx" ON "team_trophies"("season");

-- CreateIndex
CREATE INDEX "player_trophies_person_id_competition_id_idx" ON "player_trophies"("person_id", "competition_id");

-- CreateIndex
CREATE INDEX "player_trophies_season_idx" ON "player_trophies"("season");

-- CreateIndex
CREATE INDEX "manager_trophies_person_id_competition_id_idx" ON "manager_trophies"("person_id", "competition_id");

-- CreateIndex
CREATE INDEX "manager_trophies_season_idx" ON "manager_trophies"("season");

-- AddForeignKey
ALTER TABLE "teams" ADD CONSTRAINT "teams_league_id_fkey" FOREIGN KEY ("league_id") REFERENCES "leagues"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "player_profiles" ADD CONSTRAINT "player_profiles_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "persons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "player_profiles" ADD CONSTRAINT "player_profiles_current_team_id_fkey" FOREIGN KEY ("current_team_id") REFERENCES "teams"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_profiles" ADD CONSTRAINT "manager_profiles_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "persons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_profiles" ADD CONSTRAINT "manager_profiles_current_team_id_fkey" FOREIGN KEY ("current_team_id") REFERENCES "teams"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "player_career" ADD CONSTRAINT "player_career_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "persons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "player_career" ADD CONSTRAINT "player_career_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "teams"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "player_career" ADD CONSTRAINT "player_career_league_id_fkey" FOREIGN KEY ("league_id") REFERENCES "leagues"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_career" ADD CONSTRAINT "manager_career_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "persons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_career" ADD CONSTRAINT "manager_career_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "teams"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_career" ADD CONSTRAINT "manager_career_league_id_fkey" FOREIGN KEY ("league_id") REFERENCES "leagues"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_trophies" ADD CONSTRAINT "team_trophies_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "teams"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_trophies" ADD CONSTRAINT "team_trophies_competition_id_fkey" FOREIGN KEY ("competition_id") REFERENCES "competitions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "player_trophies" ADD CONSTRAINT "player_trophies_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "persons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "player_trophies" ADD CONSTRAINT "player_trophies_competition_id_fkey" FOREIGN KEY ("competition_id") REFERENCES "competitions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "player_trophies" ADD CONSTRAINT "player_trophies_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "teams"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_trophies" ADD CONSTRAINT "manager_trophies_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "persons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_trophies" ADD CONSTRAINT "manager_trophies_competition_id_fkey" FOREIGN KEY ("competition_id") REFERENCES "competitions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_trophies" ADD CONSTRAINT "manager_trophies_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "teams"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "person_nationalities" ADD CONSTRAINT "person_nationalities_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "persons"("id") ON DELETE CASCADE ON UPDATE CASCADE;
