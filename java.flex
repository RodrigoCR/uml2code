%{
	/* Archivo con en el que sescribira el xml de la gerarquia de clases que se esta leyendo */
	FILE *file;

	/* Numero de lineas dle archivo */
	int num_lines = 0;	

	/* Numero de corchetes que ayuda a satar el conteniod de los metodos */
	int num_corchetes = 0;

	/* Variable de apoyo para manejar comentarios anidados */
	int comment_level = 0;

	/* Variable que cuenta el numero de clases que llevamos leidas con respecto al numero de corchetes que han abierto y cerrado */
	int not_end_class = 0;

	/* Variable que decide si ya se leeyo al menos una clase */
	int start_class = 0;

	/* Checa en el caso de que el archivo leido sea una interfaz, para asi cerrar con una etiqueta distinta */
	int start_interface = 0;
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
THROWS "throws"
EXCEPTION [A-Z](([a-zA-Z0-9,_])|{SPACES})*
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

"{"		{	not_end_class++;	}

"}"		{	
			not_end_class--;
			if(not_end_class == 0) {
				if(start_interface) {
					printf("</interface>\n");
					start_interface = 0;
				} else {
					printf("</class>\n");
				}
			}				
		}



{IMPORT}{SPACES}{NAMEIMPORT}		{
	/*Cacha la declaracion de importaciones, pero no hace nada */
}

{PACKAGE}{SPACES}{NAMEPACKAGE}		{
	/* Cacha la declaracion del paquete donde se almacena la clase, pero no hace nada */
}


({ALEVEL}{SPACES})?{CLASS}{SPACES}{NAMECLASS}		{
	/* Cacha el nombre de una clase que no contenga final o abstrac */

	int index = 0, j = 0, i = 0, mac = 0;;
	
	char *accesmod = malloc(yyleng);
	char *name = malloc(yyleng);
	char *abstract = "class";

	// Escribe la clave estandar de XML si no se ha leido clase alguna anteriormente
	if(start_class == 0) {
		start_class = 1;
		printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
	}

	//	Modificador de Acceso
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	 index++;	}
	for(j = 0; j < index; j++) {	accesmod[j] = yytext[j];	} accesmod[j] = '\0';
	if(j == 5)	{
		for(mac = 0; mac < 5; mac++)
			if(accesmod[mac] != abstract[mac])	{	break;	} 
	}

	//	Nombre de la clase
	index = yyleng - 1;
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	index--;	}
	index++;
	for(j = 0; index < yyleng; j++, index++) {	name[j] = yytext[index];	}	name[j] = '\0';

	if(mac == 5) {
		printf("<class name=\"%s\" accesmod=\"protected\" abstract=\"false\" final=\"false\">\n", name);	
	} else {
		printf("<class name=\"%s\" accesmod=\"%s\" abstract=\"false\" final=\"false\">\n", name, accesmod);	
	}
}

({ALEVEL}{SPACES})?{ABSTRACT}{SPACES}{CLASS}{SPACES}{NAMECLASS}		{
	/* Cacha el nombre de una clase abstracta */

	int index = 0, j = 0, i = 0, mac = 0;;
	
	char *accesmod = malloc(yyleng);
	char *name = malloc(yyleng);
	char *abstract = "abstract";

	// Escribe la clave estandar de XML si no se ha leido clase alguna anteriormente
	if(start_class == 0) {
		start_class = 1;
		printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
	}

	//	Modificador de Acceso
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	 index++;	}
	for(j = 0; j < index; j++) {	accesmod[j] = yytext[j];	} accesmod[j] = '\0';
	if(j == 8)	{
		for(mac = 0; mac < 8; mac++)
			if(accesmod[mac] != abstract[mac])	{	break;	} 
	}

	//	Nombre de la clase
	index = yyleng - 1;
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	index--;	}
	index++;
	for(j = 0; index < yyleng; j++, index++) {	name[j] = yytext[index];	}	name[j] = '\0';

	if(mac == 8) {
		printf("<class name=\"%s\" accesmod=\"protected\" abstract=\"true\" final=\"false\">\n", name);	
	} else {
		printf("<class name=\"%s\" accesmod=\"%s\" abstract=\"true\" final=\"false\">\n", name, accesmod);	
	}
}

({ALEVEL}{SPACES})?{FINAL}{SPACES}{CLASS}{SPACES}{NAMECLASS}		{
	/* Cacha el nombre de una clase final */
	
	int index = 0, j = 0, i = 0, mac = 0;;
	
	char *accesmod = malloc(yyleng);
	char *name = malloc(yyleng);
	char *abstract = "final";

	// Escribe la clave estandar de XML si no se ha leido clase alguna anteriormente
	if(start_class == 0) {
		start_class = 1;
		printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
	}

	//	Modificador de Acceso
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	 index++;	}
	for(j = 0; j < index; j++) {	accesmod[j] = yytext[j];	} accesmod[j] = '\0';
	if(j == 5)	{
		for(mac = 0; mac < 5; mac++)
			if(accesmod[mac] != abstract[mac])	{	break;	} 
	}

	//	Nombre de la clase
	index = yyleng - 1;
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	index--;	}
	index++;
	for(j = 0; index < yyleng; j++, index++) {	name[j] = yytext[index];	}	name[j] = '\0';

	if(mac == 5) {
		printf("<class name=\"%s\" accesmod=\"protected\" abstract=\"false\" final=\"true\">\n", name);	
	} else {
		printf("<class name=\"%s\" accesmod=\"%s\" abstract=\"false\" final=\"true\">\n", name, accesmod);	
	}
}

({ALEVEL}{SPACES})?{INTERFACE}{SPACES}{NAMECLASS} {
	/* Cacha el nombre de una interfaz ademas de la lectura de su estructura */

	// Indica el inicio de una interface
	start_interface = 1;

	int index = 0, j = 0, i = 0, mac = 0;;
	
	char *accesmod = malloc(yyleng);
	char *name = malloc(yyleng);
	char *abstract = "interface";

	// Escribe la clave estandar de XML si no se ha leido clase alguna anteriormente
	if(start_class == 0) {
		start_class = 1;
		printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
	}

	//	Modificador de Acceso
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	 index++;	}
	for(j = 0; j < index; j++) {	accesmod[j] = yytext[j];	} accesmod[j] = '\0';
	if(j == 9)	{
		for(mac = 0; mac < 9; mac++)
			if(accesmod[mac] != abstract[mac])	{	break;	} 
	}

	//	Nombre de la clase
	index = yyleng - 1;
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	index--;	}
	index++;
	for(j = 0; index < yyleng; j++, index++) {	name[j] = yytext[index];	}	name[j] = '\0';

	if(mac == 9) {
		printf("<interface name=\"%s\" accesmod=\"protected\">\n", name);	
	} else {
		printf("<interface name=\"%s\" accesmod=\"%s\">\n", name, accesmod);	
	}	
}


{EXTENDS}{SPACES}{NAMECLASS} { /* FALTA IMPLEMENTAR EXTIEND	AND IMPLEMENTS */
	/* Cacha la clase de la cual extiende la clase actual *
	printf("Extiende a: %s\n", yytext);
}

{IMPLEMENTS}{SPACES}{NAMEINTERFACE} {
	/* Cacha el nombre de las interfases que implementa la clase actual */
	printf("Implementa a: %s\n", yytext);

}



({ALEVEL}{SPACES})?{STATIC}{SPACES}{FINAL}{SPACES}{RETURN}{SPACES}.+";"	{
	/* Cacha el nombre de variables que contengan static */
		
	int index = 0, j = 0, i = 0, mod = 0;;
	
	char *accesmod = malloc(yyleng);
	char *retorno = malloc(yyleng);
	char *name = malloc(yyleng);
	char *statico = "static";

	//	Modificador de Acceso
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	 index++;	}
	for(j = 0; j < index; j++) {	accesmod[j] = yytext[j];	} accesmod[j] = '\0';
	if(j == 6)	{
		for(mod = 0; mod < 6; mod++)
			if(accesmod[mod] != statico[mod])	{	break;	} 
	}
	if(mod == 6)	{
		accesmod = "protected";
		while(yytext[index] == ' ' || yytext[index] == '\t')	{	index++;	}
		while(yytext[index] != ' ' && yytext[index] != '\t')	{	index++;	}
	} else {
		while(yytext[index] == ' ' || yytext[index] == '\t')	{	index++;	}
		while(yytext[index] != ' ' && yytext[index] != '\t')	{	index++;	}
		while(yytext[index] == ' ' || yytext[index] == '\t')	{	index++;	}
		while(yytext[index] != ' ' && yytext[index] != '\t')	{	index++;	}
	}

	//	Tipo de Retorno	
	while(yytext[index] == ' ' || yytext[index] == '\t')	{	index++;	}
	for(j = 0; yytext[index]!=' ' && yytext[index]!='\t'; j++, index++)	{	retorno[j] = yytext[index];	} retorno[j] = '\0';

	//	Nombre de las variables
	
	while(yytext[index] != ';') {
		while(yytext[index] == ' ' || yytext[index] == '\t' || yytext[index] == ',')	{	index++;	}
		for(j = 0; yytext[index]!=' ' && yytext[index]!='\t' && yytext[index]!='=' && yytext[index]!=',' && yytext[index]!=';'; j++, index++)	{	name[j] = yytext[index];	} name[j] = '\0';
		printf("<var accesmod=\"%s\" type=\"%s\" static=\"true\" final=\"true\">%s</var>\n", accesmod, retorno, name);
		while(yytext[index] != ',' && yytext[index] != ';')	{	index++;	}
	}
}

({ALEVEL}{SPACES})?{STATIC}{SPACES}{RETURN}{SPACES}{NAMEVAR}	{
	/* Cacha el nombre de variables que contengan static */
	
		int index = 0, j = 0, i = 0, mod = 0;;
	
	char *accesmod = malloc(yyleng);
	char *retorno = malloc(yyleng);
	char *name = malloc(yyleng);
	char *statico = "static";

	//	Modificador de Acceso
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	 index++;	}
	for(j = 0; j < index; j++) {	accesmod[j] = yytext[j];	} accesmod[j] = '\0';
	if(j == 6)	{
		for(mod = 0; mod < 6; mod++)
			if(accesmod[mod] != statico[mod])	{	break;	} 
	}
	if(mod == 6)	{
		accesmod = "protected";
	} else {
		while(yytext[index] == ' ' || yytext[index] == '\t')	{	index++;	}
		while(yytext[index] != ' ' && yytext[index] != '\t')	{	index++;	}
	}

	//	Tipo de Retorno	
	while(yytext[index] == ' ' || yytext[index] == '\t')	{	index++;	}
	for(j = 0; yytext[index]!=' ' && yytext[index]!='\t'; j++, index++)	{	retorno[j] = yytext[index];	} retorno[j] = '\0';

	//	Nombre de las variables
	
	while(yytext[index] != ';') {
		while(yytext[index] == ' ' || yytext[index] == '\t' || yytext[index] == ',')	{	index++;	}
		for(j = 0; yytext[index]!=' ' && yytext[index]!='\t' && yytext[index]!='=' && yytext[index]!=',' && yytext[index]!=';'; j++, index++)	{	name[j] = yytext[index];	} name[j] = '\0';
		printf("<var accesmod=\"%s\" type=\"%s\" static=\"true\" final=\"false\">%s</var>\n", accesmod, retorno, name);
		while(yytext[index] != ',' && yytext[index] != ';')	{	index++;	}
	}
}

({ALEVEL}{SPACES})?{FINAL}{SPACES}{RETURN}{SPACES}.+";"	{
	/* Cacha el nombre de variables que contengan final */
	
	int index = 0, j = 0, i = 0, mod = 0;;
	
	char *accesmod = malloc(yyleng);
	char *retorno = malloc(yyleng);
	char *name = malloc(yyleng);
	char *final = "final";

	//	Modificador de Acceso
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	 index++;	}
	for(j = 0; j < index; j++) {	accesmod[j] = yytext[j];	} accesmod[j] = '\0';
	if(j == 5)	{
		for(mod = 0; mod < 5; mod++)
			if(accesmod[mod] != final[mod])	{	break;	} 
	}
	if(mod == 5)	{
		accesmod = "protected";
	} else {
		while(yytext[index] == ' ' || yytext[index] == '\t')	{	index++;	}
		while(yytext[index] != ' ' && yytext[index] != '\t')	{	index++;	}
	}

	//	Tipo de Retorno	
	while(yytext[index] == ' ' || yytext[index] == '\t')	{	index++;	}
	for(j = 0; yytext[index]!=' ' && yytext[index]!='\t'; j++, index++)	{	retorno[j] = yytext[index];	} retorno[j] = '\0';

	//	Nombre de las variables
	
	while(yytext[index] != ';') {
		while(yytext[index] == ' ' || yytext[index] == '\t' || yytext[index] == ',')	{	index++;	}
		for(j = 0; yytext[index]!=' ' && yytext[index]!='\t' && yytext[index]!='=' && yytext[index]!=',' && yytext[index]!=';'; j++, index++)	{	name[j] = yytext[index];	} name[j] = '\0';
		printf("<var accesmod=\"%s\" type=\"%s\" static=\"false\" final=\"true\">%s</var>\n", accesmod, retorno, name);
		while(yytext[index] != ',' && yytext[index] != ';')	{	index++;	}
	}
}

({ALEVEL}{SPACES})?{RETURN}{SPACES}{NAMEVAR}	{
	/* Cacha el nombre de variables que no contengan final y que ni static */

	int index = 0, j = 0, i = 0, mod = 0;;
	
	char *accesmod = malloc(yyleng);
	char *retorno = malloc(yyleng);
	char *name = malloc(yyleng);
	char *public = "public";
	char *protected = "protected";
	char *private  = "private";

	//	Modificador de Acceso
	while(yytext[index] != ' '  &&  yytext[index] != '\t') {	 index++;	}
	for(j = 0; j < index; j++) {	accesmod[j] = yytext[j];	} accesmod[j] = '\0';
	switch(j) {
		case 6: 
			for(mod = 0; mod < 6; mod++)
				if(accesmod[mod] != public[mod]) 
					break;
			break;
		case 9:
			for(mod = 0; mod < 9; mod++)
				if(accesmod[mod] != protected[mod]) 
					break;
			break;
		case 7:
			for(mod = 0; mod < 7; mod++)
				if(accesmod[mod] != private[mod]) 
					break;
			break;	
	}
	if(mod != 6 && mod != 9 && mod != 7)
		accesmod = "protected";

	//	Tipo de Retorno	
	while(yytext[index] == ' ' || yytext[index] == '\t')	{	index++;	}
	for(j = 0; yytext[index]!=' ' && yytext[index]!='\t'; j++, index++)	{	retorno[j] = yytext[index];	} retorno[j] = '\0';

	//	Nombre de las variables
	
	while(yytext[index] != ';') {
		while(yytext[index] == ' ' || yytext[index] == '\t' || yytext[index] == ',')	{	index++;	}
		for(j = 0; yytext[index]!=' ' && yytext[index]!='\t' && yytext[index]!='=' && yytext[index]!=',' && yytext[index]!=';'; j++, index++)	{	name[j] = yytext[index];	} name[j] = '\0';
		printf("<var accesmod=\"%s\" type=\"%s\" static=\"false\" final=\"false\">%s</var>\n", accesmod, retorno, name);
		while(yytext[index] != ',' && yytext[index] != ';')	{	index++;	}
	}
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



({ALEVEL}{SPACES})?{NAMECONTRUCT}({SPACES}{THROWS}{SPACES}{EXCEPTION})?	{
	/* Cacha la estructura de contructores */
	if(start_interface == 0)
		BEGIN(metodo);
	//printf("Constructor :%s\n", yytext);
}

({ALEVEL}{SPACES})?{RETURN}{SPACES}{NAMEMETHOD}({SPACES}{THROWS}{SPACES}{EXCEPTION})? { 
	/* Cacha la estructuctura de un metodo que no contenga final ni abstract */
	if(start_interface == 0)
		BEGIN(metodo);
	//printf("Metodo :%s\n", yytext);
}

({ALEVEL}{SPACES})?{STATIC}{SPACES}{RETURN}{SPACES}{NAMEMETHOD}({SPACES}{THROWS}{SPACES}{EXCEPTION})?	{
	/* Cacha la estructura de los metodos de clase, es decir, los que contienen static en su nombre */
	if(start_interface == 0)
		BEGIN(metodo);
	//printf("Metodo de Clase :%s\n", yytext);
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
