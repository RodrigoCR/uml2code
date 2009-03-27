%{ 
int num_lines = 0;
int num_level = 0;
%} 

ALEVEL ""|"__"
CLASS "class"
FUNCTION "def"
CNAME [A-Z][a-zA-Z0-9_]*
FNAME [a-z][a-zA-Z0-9_]*
EXTENDS ""|"("+[A-Z][a-zA-Z0-9_]*+")"
COMMENT "#"
VARS ""|[a-zA-Z]*|[a-zA-Z0-9_]*[','][' ']*

%% 
\n     {
	num_lines++;
	num_level=0;
}
\t     {num_level++;}

{CLASS}+" "+{ALEVEL}+{CNAME}+{EXTENDS}     {
	char *nom = NULL;
	char *extends = NULL;
	int alevel = 0, exts=0, lclassn, lextcn;
	int i, j, temp;
	if(yytext[6] == '_'){
		i = 8;
		temp = 7;
		alevel = 1;
	} else {
		i = 6;
		temp = 5;
	}
	for(j = i; j < yyleng; j++){
		if(yytext[j] == '('){
			i = j - 1;
			exts = 1;
			break; break;
		}
	}
	if(exts == 0)
		i = yyleng - 1;
	lclassn = i - temp;
	lextcn = yyleng - i - 1;
	nom = malloc(lclassn);
	extends = malloc(lextcn);
	for(j = 0; j < lclassn; ++j){
		nom[j] = yytext[j + temp + 1];
	}
	for(j = 0; j < lextcn; ++j){
		extends[j] = yytext[j + temp + lclassn + 2];
	}
	printf("Found class: %s\n", nom);
	if(exts==0) { 
		printf("This class extends from: object\n");
	} else {
		printf("This class extends from: %s\n", extends);
	}
	if(alevel == 1)
		printf("This class is: private\n");
	else
		printf("This class is: public\n");
	free(nom);
	free(extends);
}

{FUNCTION}+" "+{ALEVEL}+{FNAME}+"("+{VARS}+")"     {
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
	printf("Encontré una función: %s\n", yytext);
	free(nom);
}

.	{}

%% 
main() 
{ 
  yylex(); 
  printf( "Parsed %d lines\nEnd of execution\n", num_lines); 
}
