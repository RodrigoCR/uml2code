%{

FILE *f;

int num_lines = 0;
int opened_class = 0;
int opened_method = 0;
int is_class = 0;
int is_var = 0;
int is_method = 0;
int nvars = 0;
char* nombre;

void ptabs(int num) {
	int i;
	for(i = 0; i < num; i++)
		fprintf(f, "\t");	
}

%}

CLASSO "<class>"
CLASSC "</class>"

METO "<method>"
METC "</method>"

VARO "<var>"

NAMEO "<name> "
NAMEC " </name>"

RECO "<receives>"
RECC "</receives>"

EXTO "<extends> "
EXTC " </extends>"

ACCO "<accmod> "
ACCC " </accmod>"

CONTO "<content>"
CONTC "</content>"

NAME [a-zA-Z_][a-zA-Z0-9_]*

SLCOMO "<slcomment>"
SLCOMC "</slcomment>"

MLCOMO "<mlcomment>"
MLCOMC "</mlcomment>"


%x content
%x slcom
%x mlcom

%% 

\n     {
	num_lines++;
}

<content>{
	\n     {
		num_lines++;
		fprintf(f,"\n");
	}

	{CONTC}     {
		BEGIN(INITIAL);
	}

	.	{
		fprintf(f,"%s", yytext);
	}
}

<slcom>{
	\n     {
		num_lines++;
	}

	{SLCOMC}     {
		fprintf(f,"\n");
		BEGIN(INITIAL);
	}

	.	{
		fprintf(f,"%s", yytext);
	}
}

<mlcom>{
	\n     {
		num_lines++;
		fprintf(f,"\n");
	}

	{MLCOMC}     {
		ptabs(opened_class);
		fprintf(f,"'''\n");
		BEGIN(INITIAL);
	}

	.	{
		fprintf(f,"%s", yytext);
	}
}

{SLCOMO}     {
	fprintf(f,"\n");
	ptabs(opened_class);
	fprintf(f,"#");
	BEGIN(slcom);
}

{MLCOMO}     {
	fprintf(f,"\n");
	ptabs(opened_class);
	fprintf(f,"'''");
	BEGIN(mlcom);
}

{CONTO}     {
	BEGIN(content);
}

{CLASSO}     {
	fprintf(f,"\n");
	ptabs(opened_class);
	fprintf(f,"class ");
	is_class = 1;
	opened_class++;
}
{CLASSC}     {
	opened_class--;
}

{VARO}     {
	is_var = 1;
	nvars++;
}

{METO}     {
	fprintf(f,"\n");
	ptabs(opened_class);
	fprintf(f,"def ");
	is_method = 1;
	nvars = 0;
}

{METC}     {
	is_method = 0;
}

{NAMEO}+{NAME}+{NAMEC}     {
	int i, ns = yyleng - 15 + 1;
	char* nuevo = NULL;
	nuevo = malloc(sizeof(char)*ns);
	for(i=0;i<ns;i++){
		nuevo[i] = yytext[i + 7];
	}
	nuevo[ns - 1] = '\0';
	nombre = nuevo;
	if(is_var == 1){
		if(is_method == 0) {
			ptabs(opened_class);
			fprintf(f,"%s = 0\n", nombre);
		} else {
			if(nvars > 1)
				fprintf(f,", ");
			fprintf(f,"%s", nombre);
		}
		is_var = 0;
	}
}

{EXTO}+{NAME}+{EXTC}     {
	int i, ns = yyleng - 21 + 1;
	char* nuevo = NULL;
	nuevo = malloc(sizeof(char)*ns);
	for(i=0;i<ns;i++){
		nuevo[i] = yytext[i + 10];
	}
	nuevo[ns - 1] = '\0';
	nombre = strcat(nombre,"(");
	nombre = strcat(nombre, nuevo);
	nombre = strcat(nombre, ")");
}

{ACCO}+{NAME}+{ACCC}     {
	int i, ns = yyleng - 19 + 1;
	char* nuevo = NULL;
	nuevo = malloc(sizeof(char)*ns);
	for(i=0;i<ns;i++){
		nuevo[i] = yytext[i + 9];
	}
	nuevo[ns - 1] = '\0';
	
	if(strcmp(nuevo,"private") == 0){
		fprintf(f,"__");
	}
	if(is_class == 1) {
		nombre = strcat(nombre,":\n");
		is_class = 0;
	}
	fprintf(f,"%s",nombre);
}

{RECO}     {
	fprintf(f,"(");
}

{RECC}     {
	fprintf(f, "):\n");
	nvars = 0;
}

.	{
}

%%

int main(int argc, char* argv[]){

	char* newname = strcat(argv[1], ".py");
	f = fopen(newname,"w");
	
	fprintf(f,"#!/usr/bin/python\n# -*- coding: utf8 -*-\n");
	fprintf(f,"\n# Remeber to do your imports here\n\n");
	
	yylex();

  	fclose(f);
  	printf( "---\nParsed %d lines\nEnd of execution\n", num_lines);
  	return 0;
}
