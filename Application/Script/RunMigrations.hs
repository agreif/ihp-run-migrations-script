#!/usr/bin/env run-script
module Application.Script.RunMigrations where

import Application.Script.Prelude hiding (run)
import IHP.SchemaMigration

run :: Script
run = migrate $ MigrateOptions Nothing
