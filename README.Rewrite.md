> ⚠️ **This readme details a rewrite that was never completed, for reasons explained in the general README.md**

# MensaUnisa/Cacher
Software to convert the University of Salerno's online published menus to 
a database and download them in different formats.

All data downloaded is, obviously, in Italian.

Can be run in both persistent and one-off mode.

## Variables
`STARTING_ID`: Files for the UniSa's refectory are stored on the ADiSURC server 
with an unique numerical ID. The software scrapes all of them starting from either
the latest ID processed or `$STARTING_ID` if it's the first time it's run. By default
this is 3370, but it'll get probably updated when file number 3370 becomes too old.

`DATADIR`: The directory where you're storing the files downloaded and converted.
Default value is `$HOME/adisurc`.

`CONVERT_PNG`: Set to any value if the PDF should be converted to a PNG. Requires
the Arial and Times New Roman fonts, or the Liberation fonts.

`DATABASE`: See the [Database](#database) section

`SCHEDULE`: If set, the software runs in persistent mode. It must be a valid cron
string, except obviously for the absence of a command. [See here for more information
on cron strings](https://pubs.opengroup.org/onlinepubs/9699919799/).

## Storage Formats
The menus are stored in the following formats (`id` is used here in place of the
file's ID on the ADiSURC website):

### Raw PDF (`id`.pdf)
This is the PDF as it's stored on the ADiSuRC's servers. Currently it means it gets 
converted from a (probably) manually-generated Word document, but this might change
in the future. We'll take care of that when we get there.

### PNG (`id`.png)
This is the PDF file converted to PNG.

### Text (`id`.txt)
This is the PDF file converted to a text file in the following format:
```
First servings
---
Second servings
---
Third servings ("Contorno"s)
---
Contents of the Take-Away Basket
```
Every one of these servings is a list of possible meals for that serving, separated
by a newline (`\n`).

## Database
This software uses a database to store most of its data. The current supported 
databases are Postgres and SQLite.

### Environment Variables
The following environment variables are required, based on the Database you're
using:
#### SQLite
`DATABASE`: Must be set to `sqlite`;  
`SQLITE_FILE`: Must be the path to the `sqlite` database file;

#### Postgres
If using Postgres, a `mensaunisa` role should exist and the user this software
connects through should be in it. Additionally, the user should be able to create
tables in the database.

`DATABASE`: Must be set to `postgres`;  
`POSTGRES_URL`: Must be the URL to the Postgres server;  
`POSTGRES_PORT`: Must be the Port of the Postgres server. Defaults to 5432;  
`POSTGRES_DATABASE`: Must be the database used by the software. Defaults to `mensaunisa`;  
`POSTGRES_USER`: Must be the username with which to connect to the Postgres server.
Defaults to `mensaunisacacher`;  
`POSTGRES_PASSWORD`: The password to login as `POSTGRES_USER`;

### Structure of the database

#### menus
This table contains data about the individual menus.

It has the following three columns:
* `id` is the numeric `id` of the file that corresponds to the menu on the ADiSURC
servers. This is supposed to be unique;
* `date` is the date corresponding to the menu, in YYYYMMDD format;
* `meal` is the specific meal represented. It can be `0` for lunch, and `1` for dinner

Note that there might be multiple menus for the same day (the date/meal combo is
NOT guaranteed to be unique). This is because the ADiSURC uploads corrections and
changes to the menus as entirely new files. As such, it's suggested that if you
need a specific day's menu you fetch the one with the highest id for the specified
date.

#### dishes
This table contains data about the individual dishes served.

It has the following three columns:
* `id` is the numeric `id` of the menu this dish is part of;
* `serving` is the specific serving represented. `0-2` for First, Second and Third
serving, `3` for the contents of the takeaway basket;
* `contents` is the actual dish as described on the menu

## Dockerfile
You may run this through Docker by mounting a volume to `/adisurc` (or passing your
own `DATADIR` environment variable and mounting the volume there). The Dockerfile
is extremely simple and based on the `alpine` image. It contains the `ttf-liberation`
package and thus supports the `CONVERT_PNG` option.

## License Compliance
This is the official stance of the ADiSURC, in Italian, on using their website content:

> I file presenti in questo sito per lo scaricamento (download) quali ad esempio
> la modulistica sono liberamente e gratuitamente disponibili. La riproduzione o
> l'impiego di informazioni testuali e multimediali (suoni, immagini, software ecc.)
> sono consentiti con indicazione della fonte e, qualora sia richiesta un'autorizzazione
> preliminare, questa indicherà esplicitamente ogni eventuale restrizione.

As such, if you use any file generated by this application, it is suggested that
you specify the source as "Azienda per il Diritto allo Studio Universitario della
Regione Campania via adisurcampania.it".
