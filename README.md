# ihp-run-migrations-script
IHP standalone Script to run migrations

## Why?
**TL;DR**

On the production server, where the server executable is running I also need a way to run the pending DB migrations.

This Script can be compiled into an executable and shipped to the prod server together with the server executable,
so that I dont have to install the IHP development framework on the prod system.

**Long version:**

On the development server, where all dev tools, compilers, etc are installed, running the migrations from the command line is described in the [Running Migrations](https://ihp.digitallyinduced.com/Guide/database-migrations.html#running-migrations) chapter and works like this:
```
$ cd my-ihp-project

$ DATABASE_URL=postgresql://... migrate
```

The problem is that the `migrate` script is installed by the IHP framework, that needs Nix and other development tools.

But on the production server we don't want any of these development tools and frameworks for security reasons.

In the prod environment I only want ready to run monolythic exetubales like the generated IHP Server app that is created like this:
```
$ nix-build

$ tree result/bin/
result/bin/
├── RunProdServer
└── RunProdServerWithoutOptions
```

## Solution
The Script in this repo does only one thing, it runs the migrations.
IHP determines internally which migrations are already there and which are pending, then the pending ones are executed.

Fortunately [IHP Scripts](https://ihp.digitallyinduced.com/Guide/scripts.html) can also be compiled into a standalone executable like the server app itself.

The script has to be saved here:
```
$ tree Application/Script/
Application/Script/
└── RunMigrations.hs
```

and contains only one line to run the migrations:
```
...
run :: Script
run = migrate $ MigrateOptions Nothing
```

Building the project also compiles the Script beside the main app, so that the `result/bin/` directory looks like this with the additional `RunMigrations` executable:
```
$ nix-build

$ tree result/bin/
result/bin/
├── RunMigrations
├── RunProdServer
└── RunProdServerWithoutOptions
```

Now you can ship these executables to the production server and run them standalone:
```
$ DATABASE_URL=postgresql://...   ./RunMigrations

$ DATABASE_URL=postgresql://...   ./RunProdServer
```

The `RunMigrations` executable should be configured in systemd to run before the server itself starts.
