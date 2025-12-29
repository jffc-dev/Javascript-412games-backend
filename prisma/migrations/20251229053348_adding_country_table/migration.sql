/*
  Warnings:

  - The primary key for the `competitions` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The primary key for the `leagues` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `country` on the `leagues` table. All the data in the column will be lost.
  - The primary key for the `manager_career` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The primary key for the `manager_profiles` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `person_id` on the `manager_profiles` table. All the data in the column will be lost.
  - The primary key for the `manager_trophies` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The primary key for the `person_nationalities` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `nationality` on the `person_nationalities` table. All the data in the column will be lost.
  - The primary key for the `persons` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `nationality` on the `persons` table. All the data in the column will be lost.
  - The primary key for the `player_career` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The primary key for the `player_profiles` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `person_id` on the `player_profiles` table. All the data in the column will be lost.
  - The primary key for the `player_trophies` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The primary key for the `team_trophies` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The primary key for the `teams` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `country` on the `teams` table. All the data in the column will be lost.
  - The required column `personId` was added to the `manager_profiles` table with a prisma-level default value. This is not possible if the table is not empty. Please add this column as optional, then populate it before making it required.
  - Added the required column `country_id` to the `person_nationalities` table without a default value. This is not possible if the table is not empty.
  - The required column `personId` was added to the `player_profiles` table with a prisma-level default value. This is not possible if the table is not empty. Please add this column as optional, then populate it before making it required.

*/
-- DropForeignKey
ALTER TABLE "manager_career" DROP CONSTRAINT "manager_career_league_id_fkey";

-- DropForeignKey
ALTER TABLE "manager_career" DROP CONSTRAINT "manager_career_person_id_fkey";

-- DropForeignKey
ALTER TABLE "manager_career" DROP CONSTRAINT "manager_career_team_id_fkey";

-- DropForeignKey
ALTER TABLE "manager_profiles" DROP CONSTRAINT "manager_profiles_current_team_id_fkey";

-- DropForeignKey
ALTER TABLE "manager_profiles" DROP CONSTRAINT "manager_profiles_person_id_fkey";

-- DropForeignKey
ALTER TABLE "manager_trophies" DROP CONSTRAINT "manager_trophies_competition_id_fkey";

-- DropForeignKey
ALTER TABLE "manager_trophies" DROP CONSTRAINT "manager_trophies_person_id_fkey";

-- DropForeignKey
ALTER TABLE "manager_trophies" DROP CONSTRAINT "manager_trophies_team_id_fkey";

-- DropForeignKey
ALTER TABLE "person_nationalities" DROP CONSTRAINT "person_nationalities_person_id_fkey";

-- DropForeignKey
ALTER TABLE "player_career" DROP CONSTRAINT "player_career_league_id_fkey";

-- DropForeignKey
ALTER TABLE "player_career" DROP CONSTRAINT "player_career_person_id_fkey";

-- DropForeignKey
ALTER TABLE "player_career" DROP CONSTRAINT "player_career_team_id_fkey";

-- DropForeignKey
ALTER TABLE "player_profiles" DROP CONSTRAINT "player_profiles_current_team_id_fkey";

-- DropForeignKey
ALTER TABLE "player_profiles" DROP CONSTRAINT "player_profiles_person_id_fkey";

-- DropForeignKey
ALTER TABLE "player_trophies" DROP CONSTRAINT "player_trophies_competition_id_fkey";

-- DropForeignKey
ALTER TABLE "player_trophies" DROP CONSTRAINT "player_trophies_person_id_fkey";

-- DropForeignKey
ALTER TABLE "player_trophies" DROP CONSTRAINT "player_trophies_team_id_fkey";

-- DropForeignKey
ALTER TABLE "team_trophies" DROP CONSTRAINT "team_trophies_competition_id_fkey";

-- DropForeignKey
ALTER TABLE "team_trophies" DROP CONSTRAINT "team_trophies_team_id_fkey";

-- DropForeignKey
ALTER TABLE "teams" DROP CONSTRAINT "teams_league_id_fkey";

-- DropIndex
DROP INDEX "persons_nationality_idx";

-- AlterTable
ALTER TABLE "competitions" DROP CONSTRAINT "competitions_pkey",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ADD CONSTRAINT "competitions_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "competitions_id_seq";

-- AlterTable
ALTER TABLE "leagues" DROP CONSTRAINT "leagues_pkey",
DROP COLUMN "country",
ADD COLUMN     "country_id" TEXT,
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ADD CONSTRAINT "leagues_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "leagues_id_seq";

-- AlterTable
ALTER TABLE "manager_career" DROP CONSTRAINT "manager_career_pkey",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ALTER COLUMN "person_id" SET DATA TYPE TEXT,
ALTER COLUMN "team_id" SET DATA TYPE TEXT,
ALTER COLUMN "league_id" SET DATA TYPE TEXT,
ADD CONSTRAINT "manager_career_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "manager_career_id_seq";

-- AlterTable
ALTER TABLE "manager_profiles" DROP CONSTRAINT "manager_profiles_pkey",
DROP COLUMN "person_id",
ADD COLUMN     "personId" TEXT NOT NULL,
ALTER COLUMN "current_team_id" SET DATA TYPE TEXT,
ADD CONSTRAINT "manager_profiles_pkey" PRIMARY KEY ("personId");

-- AlterTable
ALTER TABLE "manager_trophies" DROP CONSTRAINT "manager_trophies_pkey",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ALTER COLUMN "person_id" SET DATA TYPE TEXT,
ALTER COLUMN "competition_id" SET DATA TYPE TEXT,
ALTER COLUMN "team_id" SET DATA TYPE TEXT,
ADD CONSTRAINT "manager_trophies_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "manager_trophies_id_seq";

-- AlterTable
ALTER TABLE "person_nationalities" DROP CONSTRAINT "person_nationalities_pkey",
DROP COLUMN "nationality",
ADD COLUMN     "country_id" TEXT NOT NULL,
ALTER COLUMN "person_id" SET DATA TYPE TEXT,
ADD CONSTRAINT "person_nationalities_pkey" PRIMARY KEY ("person_id", "country_id");

-- AlterTable
ALTER TABLE "persons" DROP CONSTRAINT "persons_pkey",
DROP COLUMN "nationality",
ADD COLUMN     "country_id" TEXT,
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ADD CONSTRAINT "persons_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "persons_id_seq";

-- AlterTable
ALTER TABLE "player_career" DROP CONSTRAINT "player_career_pkey",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ALTER COLUMN "person_id" SET DATA TYPE TEXT,
ALTER COLUMN "team_id" SET DATA TYPE TEXT,
ALTER COLUMN "league_id" SET DATA TYPE TEXT,
ADD CONSTRAINT "player_career_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "player_career_id_seq";

-- AlterTable
ALTER TABLE "player_profiles" DROP CONSTRAINT "player_profiles_pkey",
DROP COLUMN "person_id",
ADD COLUMN     "personId" TEXT NOT NULL,
ALTER COLUMN "current_team_id" SET DATA TYPE TEXT,
ADD CONSTRAINT "player_profiles_pkey" PRIMARY KEY ("personId");

-- AlterTable
ALTER TABLE "player_trophies" DROP CONSTRAINT "player_trophies_pkey",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ALTER COLUMN "person_id" SET DATA TYPE TEXT,
ALTER COLUMN "competition_id" SET DATA TYPE TEXT,
ALTER COLUMN "team_id" SET DATA TYPE TEXT,
ADD CONSTRAINT "player_trophies_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "player_trophies_id_seq";

-- AlterTable
ALTER TABLE "team_trophies" DROP CONSTRAINT "team_trophies_pkey",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ALTER COLUMN "team_id" SET DATA TYPE TEXT,
ALTER COLUMN "competition_id" SET DATA TYPE TEXT,
ADD CONSTRAINT "team_trophies_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "team_trophies_id_seq";

-- AlterTable
ALTER TABLE "teams" DROP CONSTRAINT "teams_pkey",
DROP COLUMN "country",
ADD COLUMN     "country_id" TEXT,
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ALTER COLUMN "league_id" SET DATA TYPE TEXT,
ADD CONSTRAINT "teams_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "teams_id_seq";

-- CreateTable
CREATE TABLE "countries" (
    "id" TEXT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "code" CHAR(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "countries_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "countries_name_key" ON "countries"("name");

-- CreateIndex
CREATE UNIQUE INDEX "countries_code_key" ON "countries"("code");

-- CreateIndex
CREATE INDEX "persons_country_id_idx" ON "persons"("country_id");

-- AddForeignKey
ALTER TABLE "leagues" ADD CONSTRAINT "leagues_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "countries"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teams" ADD CONSTRAINT "teams_league_id_fkey" FOREIGN KEY ("league_id") REFERENCES "leagues"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teams" ADD CONSTRAINT "teams_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "countries"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "persons" ADD CONSTRAINT "persons_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "countries"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "player_profiles" ADD CONSTRAINT "player_profiles_personId_fkey" FOREIGN KEY ("personId") REFERENCES "persons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "player_profiles" ADD CONSTRAINT "player_profiles_current_team_id_fkey" FOREIGN KEY ("current_team_id") REFERENCES "teams"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_profiles" ADD CONSTRAINT "manager_profiles_personId_fkey" FOREIGN KEY ("personId") REFERENCES "persons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

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

-- AddForeignKey
ALTER TABLE "person_nationalities" ADD CONSTRAINT "person_nationalities_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "countries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
