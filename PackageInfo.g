# SPDX-License-Identifier: GPL-2.0-or-later
# ArangoDBInterface: A GAP interface to ArangoDB
#
# This file contains package meta data. For additional information on
# the meaning and correct usage of these fields, please consult the
# manual of the "Example" package as well as the comments in its
# PackageInfo.g file.
#
SetPackageInfo( rec(

PackageName := "ArangoDBInterface",
Subtitle := "A GAP interface to ArangoDB",
Version := Maximum( [
                   "2020.10-01", ## Mohamed's version
                   ## this line prevents merge conflicts
                   "2017.07-21", ## Lukas's version
                   ] ),

Date := ~.Version{[ 1 .. 10 ]},
Date := Concatenation( "01/", ~.Version{[ 6, 7 ]}, "/", ~.Version{[ 1 .. 4 ]} ),
License := "GPL-2.0-or-later",


Persons := [
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Mohamed",
    LastName := "Barakat",
    WWWHome := "https://mohamed-barakat.github.io/",
    Email := "mohamed.barakat@uni-siegen.de",
    PostalAddress := Concatenation(
               "Walter-Flex-Str. 3\n",
               "57068 Siegen\n",
               "Germany" ),
    Place := "Siegen",
    Institution := "University of Siegen",
  ),
],

# BEGIN URLS
SourceRepository := rec(
    Type := "git",
    URL := "https://github.com/homalg-project/ArangoDBInterface",
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := "https://homalg-project.github.io/ArangoDBInterface",
PackageInfoURL  := "https://homalg-project.github.io/ArangoDBInterface/PackageInfo.g",
README_URL      := "https://homalg-project.github.io/ArangoDBInterface/README.md",
ArchiveURL      := Concatenation( "https://github.com/homalg-project/ArangoDBInterface/releases/download/v", ~.Version, "/ArangoDBInterface-", ~.Version ),
# END URLS

ArchiveFormats := ".tar.gz .zip",

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "submitted"     for packages submitted for the refereeing
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
##
Status := "dev",

AbstractHTML   :=  "",

PackageDoc := rec(
  BookName  := "ArangoDBInterface",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "A GAP interface to ArangoDB",
),

Dependencies := rec(
  GAP := ">= 4.9.1",
  NeededOtherPackages := [
                   [ "GAPDoc", ">= 1.5" ],
                   [ "JSON", ">= 1.2.0" ],
                   [ "ToolsForHomalg", ">= 2018.11.30" ],
                   [ "HomalgToCAS", ">= 2018.11.30" ],
                   [ "IO_ForHomalg", ">= 2017.07.01" ],
                   ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := [ ],
),

AvailabilityTest := function()
        return true;
    end,

TestFile := "tst/testall.g",

Keywords := [ "ArangoDB", "arangosh", "interface" ],

));
