%{
	/* Numero de lineas dle archivo */
	int num_lines = 0;	
	/* Numero de corchetes que ayuda a satar el conteniod de los metodos */
	int num_corchetes = 0;
	/* Variable de apoyo para manejar comentarios anodados */
	int comment_level = 0;
%}

/*
 *	EXPRESIONES REGULARES PARA TODO EL LEXER 
 */
SPACES (" "|\t)+
ALEVEL ("public"|"private"|"protected")
RETURN [a-zA-Z0-9\[\]_]+
FINAL "final"
STATIC "static"
ABSTRACT "abstract"

/*
 *	EXPRESIONES REGULARES PARA DETECCION DE METODOS
 */
NATIVE "native"
SYNC "synchronized"
NAMEMETHOD [a-z][a-zA-Z0-9_]+"(".*")"
/*
 *	EXPRESIONES REGULARES PARA LA DETECCION CONTRUCTORES
 */
NAMECONTRUCT [a-zA-Z0-9_]+"(".*")"


/*
 *	EXPRESIONES REGULARES PARA LA DETECCION DE CLASES
 */
CLASS "class"
INTERFACE "interface"
NAMECLASS [a-zA-Z0-9_]+
EXTENDS "extends"
IMPLEMENTS "implements"

/*
 *	CACHA LAS PALABRAS RESERVADAS IMPORT Y PACKAGE
 */
IMPORT "import"
NAMEIMPORT [a-zA-Z0-9.*_]+";"
PACKAGE "package"
NAMEPACKAGE [a-zA-Z0-9._]+";"

/*
 *	EXPRESION REGULAR PARA LA DETECCION DE INTERFACES QUE SON IMPLEMENTADAS EN UNA CLASE
 */
NAMEINTERFACE (([a-zA-Z0-9,_]+)|{SPACES})+

/*
 *	EPSRESIONES REGULARES PARA LA DETECCION DE VARIABLES
 */
NAMEVAR (([a-zA-Z0-9,=_]+)|{SPACES})+";"

%x comment
%x metodo
%x comment_simple
%x interface

%%
\n		{ num_lines++; } /* Caza los altos de linea. */

[ \f\r\t\v]+		{}	/* Carateres no deseados */



{IMPORT}{SPACES}{NAMEIMPORT}		{
	/*Cacha la declaracion de importaciones */
	printf("Importado : %s\n", yytext);
}

{PACKAGE}{SPACES}{NAMEPACKAGE}		{
	/* Cacha la declaracion del paquete donde se almacena la clase */
	printf("Paquete : %s\n", yytext);
}


{ALEVEL}?{SPACES}?{CLASS}{SPACES}{NAMECLASS}		{
	/* Cacha el nombre de una clase que no contenga final o abstrac */
	printf("Clase : %s\n", yytext);
}

{ALEVEL}?{SPACES}?{ABSTRACT}{SPACES}{CLASS}{SPACES}{NAMECLASS}		{
	/* Cacha el nombre de una clase abstracta */
	printf("Clase Abstracta: %s\n", yytext);
}

{ALEVEL}?{SPACES}?{FINAL}{SPACES}{CLASS}{SPACES}{NAMECLASS}		{
	/* Cacha el nombre de una clase final */
	printf("Clase Final: %s\n", yytext);
}

{ALEVEL}?{SPACES}?{INTERFACE}{SPACES}{NAMECLASS} {
	/* Cacha el nombre de una interfaz ademas de la lectura de su estructura */
	//BEGIN(interface);
	printf("Interface : %s\n", yytext);
}

<interface>	{ /* Cacha el contenido de una interface de forma distinta al de una clase */

}

{EXTENDS}{SPACES}{NAMECLASS} {
	/* Cacha la clase de la cual extiende la clase actual */
	printf("Extiende a: %s\n", yytext);
}

{IMPLEMENTS}{SPACES}{NAMEINTERFACE} {
	/* Cacha el nombre de las interfases que implementa la clase actual */
	printf("Implementa a: %s\n", yytext);

}



{ALEVEL}?{SPACES}?{RETURN}{SPACES}{NAMEVAR}	{
	/* Cacha el nombre de variables que no contengan final y que ni static */
	printf("Variable : %s\n", yytext);
}

{ALEVEL}?{SPACES}?{STATIC}{SPACES}{RETURN}{SPACES}{NAMEVAR}	{
	/* Cacha el nombre de variables que contengan static */
	printf("Variable : %s\n", yytext);
}

{ALEVEL}?{SPACES}?{FINAL}{SPACES}{RETURN}{SPACES}.+";"	{
	/* Cacha el nombre de variables que contengan final */
	printf("Variable : %s\n", yytext);
}

{ALEVEL}?{SPACES}?{STATIC}{SPACES}{FINAL}{SPACES}{RETURN}{SPACES}.+";"	{
	/* Cacha el nombre de variables que contengan static */
	printf("Variable : %s\n", yytext);
}



"/*"  { BEGIN(comment); comment_level = 1; } /* Cacha el inicio de un comentario. */

<comment>{		 /* Cacha comentarios anidados */
\n                {num_lines++;}
"/*"				{comment_level++;}
"*/"				{
						comment_level--;
						if(comment_level == 0)
							BEGIN(INITIAL);
					}
.					{}
}



"//"	{	BEGIN(comment_simple);	}	/* Cacha los comentarios simples */

<comment_simple>{		/* Ignora todo lo que digan dichos comentarios */
\n		{
				num_lines++;
				BEGIN(INITIAL);					
			}
.			{}
}



<metodo>{		/* Ignora el contenido de los metodos */
\n {num_lines++;}
"{"		{num_corchetes++;}
"}"		{
			num_corchetes--;
			if(num_corchetes == 0)
				BEGIN(INITIAL);
		}
.		{}
}



{ALEVEL}?{SPACES}{NAMECONTRUCT}		{
	/* Cacha la estructura de contructores */
	BEGIN(metodo);
	printf("Constructor : %s\n", yytext);
}

{ALEVEL}?{SPACES}{RETURN}{SPACES}{NAMEMETHOD} { 
	/* Cacha la estructuctura de un metodo que no contenga final ni abstract */
	BEGIN(metodo);
	printf("Metodo : %s\n", yytext);
}

{ALEVEL}?{SPACES}{STATIC}{SPACES}{RETURN}{SPACES}{NAMEMETHOD}	{
	/* Cacha la estructura de los metodos de clase, es decir, los que contienen static en su nombre */
	BEGIN(metodo);
	printf("Metodo de Clase : %s\n", yytext);
}

. 		{} 	/* Ignora todos los carecteres distintos a las expresiones regulares que se enuncian arriba */


%%
main() 
	{
		yylex();
		printf("Fin de la ejecucion, se leyeron %d lineas.\n", num_lines);
	}

int yywrap() 
	{
		return 1;
	}
