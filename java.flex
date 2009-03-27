%{
	int num_lines = 0;	
	int num_corchetes = 0;
	int comment_level = 0;
%}

STATIC "static"
ABSTRACT "abstract"
FINAL "final"
NATIVE "native"
SYNC "synchronized"
ALEVEL "public"|"private"|"protectec"
RETURN [a-zA-Z0-9\[\]_]+
NAMEMETHOD [a-z][a-zA-Z0-9_]+"("+.*+")"

NAMECONTRUCT [a-zA-Z0-9_]+"("+.*+")"

CLASS "class"
NAMECLASS [a-zA-Z0-9_]+
EXTENDS "extends"
IMPLEMENTS "implements"

SPACES [\t\s]+

NAMEVAR [a-zA-Z0-9,_]+";"

%x comment
%x metodo

%%
\n		{ num_lines++; }

[ \f\r\t\v]+		{}

{ALEVEL}+" "+{CLASS}+" "+{NAMECLASS}		{
	printf("Clase : %s\n", yytext);
}

{EXTENDS}+" "+{NAMECLASS} {
char *nom = NULL;
nom = malloc(yyleng);
int i, espacio;
int j = 0;
for(i = yyleng-1; i > 0; --i){
	if(yytext[i] == ' '){
		espacio = i;
		break; break;
	}
}
i = 0;
for(j = espacio+1; j < yyleng; ++j){
	nom[i] = yytext[j]; 
	++i;
}
printf("Extiende a: %s\n", nom);
free(nom);
}

{IMPLEMENTS}+" "+{NAMECLASS} {
char *nom = NULL;
nom = malloc(yyleng);
int i, espacio;
int j = 0;
for(i = yyleng-1; i > 0; --i){
	if(yytext[i] == ' '){
		espacio = i;
		break; break;
	}
}
i = 0;
for(j = espacio+1; j < yyleng; ++j){
	nom[i] = yytext[j]; 
	++i;
}
printf("Implementa a: %s\n", nom);
free(nom);
}


{ALEVEL}?+" "+{RETURN}+" "+{NAMEVAR}	{
	printf("Variable : %s\n", yytext);
}



"/*"  { BEGIN(comment); comment_level = 1; }
<comment>{
\n                {num_lines++;}
"/*"				{comment_level++;}
"*/"				{
						comment_level--;
						if(comment_level == 0)
							BEGIN(INITIAL);
					}
.					{}
}


<metodo>{
\n {num_lines++;}
"{"		{num_corchetes++;}
"}"		{
			num_corchetes--;
			if(num_corchetes == 0)
				BEGIN(INITIAL);
		}
.		{}
}


{ALEVEL}?+" "+{NAMECONTRUCT}		{
	BEGIN(metodo);
	printf("Constructor : %s\n", yytext);
}


{ALEVEL}?+" "+{RETURN}+" "+{NAMEMETHOD} { 
	BEGIN(metodo);
	printf("Metodo : %s\n", yytext);
}

. {}

%%
main() 
	{
		yylex();
		printf("Fin de la ejecucion\n");
	}

int yywrap() 
	{
		return 1;
	}
