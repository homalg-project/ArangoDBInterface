#
# ArangoDBInterface: An interface to ArangoDB
#
# This file is a script which compiles the package manual.
#
if fail = LoadPackage("AutoDoc", "2016.02.16") then
    Error("AutoDoc version 2016.02.16 or newer is required.");
fi;

AutoDoc( 
        rec(
            scaffold := rec(
                gapdoc_latex_options := rec(
                LateExtraPreamble := """
                    \usepackage{amsmath}
                    \usepackage[T1]{fontenc}
                    \usepackage{tikz}
                    \usetikzlibrary{shapes,arrows,matrix}
                    \usepackage{faktor}
                    \RecustomVerbatimEnvironment{Verbatim}{BVerbatim}{}
                    """
                ),
                entities := [ "GAP4", "CAP" ],
            ),

            autodoc := rec( files := [ "doc/Doc.autodoc" ] ),

            maketest := rec( folder := ".",
                             commands :=
                             [ "LoadPackage( \"ArangoDBInterface\" );",
                               "HOMALG_IO.show_banners := false;",
                             ],
                           ),
            )
);

QUIT;
