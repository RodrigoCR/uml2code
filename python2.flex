%{ 
int num_lines = 0;
int num_level = 0;
int num_base_level = 0;
int num_chars_current_line = 0;
%} 

ALEVEL [:blank:]*(""|"__")
CLASS "class"
FUNCTION "def"
CNAME [A-Z][a-zA-Z0-9_]*
FVNAME [a-z][a-zA-Z0-9_]*
EXTENDS ""|"("+[A-Z][a-zA-Z0-9_]*+")"
SLCOMMENT "#"
MLCOMMENT "'''"
VARS ""|([a-z][a-zA-Z0-9_]*[' ']*[',']?[' ']*)*([a-z][a-zA-Z0-9_]*[' ']*)?
CONSTRUCTOR "__init__"

%x mlcomment
%x slcomment
%x method

%% 
\n     {
	num_lines++;
	num_level=0;
	num_chars_current_line = 0;
}
\t     {
	if(num_chars_current_line == 0)
		num_level++;
}
" "     {
	if(num_chars_current_line == 0)
		num_level++;
}

"'''"  { 
	BEGIN(mlcomment); 
}
"#"     {
	BEGIN(slcomment);
}

<mlcomment>{
\n     {
	num_lines++;
}
"'''"     {
	BEGIN(INITIAL);
	printf("End of multiline comment at line %d\n", num_lines + 1);
}
.     {}
}
<slcomment>{
\n     {
	num_lines++;
	BEGIN(INITIAL);
	printf("End of single line comment at line %d\n", num_lines);
}
.     {}
}

<method>{
\n     {
	num_lines++;
	num_level=0;
	num_chars_current_line = 0;
}

\t     {
	if(num_chars_current_line == 0)
		num_level++;
}
" "     {
	if(num_chars_current_line == 0)
		num_level++;
}

":"     {}

.		{
	if(num_level <= num_base_level) {
		BEGIN(INITIAL);
		printf("End of method at line %d\n", num_lines);
	}
}
}


{CLASS}+" "+{ALEVEL}+{CNAME}+{EXTENDS}     {
	int alevel = 0, exts=0, lclassn, lextcn;
	int cnstart, ecnstart, j;
	if(yytext[6] == '_'){
		cnstart = 8;
		alevel = 1;
	} else {
		cnstart = 6;
	}
	for(j = cnstart; j < yyleng; j++){
		if(yytext[j] == '('){
			ecnstart = j + 1;
			exts = 1;
			break; break;
		}
	}
	if(exts == 0) {
		lextcn = 1;
		ecnstart = yyleng + 1;
	}
	else
		lextcn = yyleng - ecnstart - 1;
	lclassn = ecnstart - 1 - cnstart;
	
	char *nom = malloc(lclassn);
	char *extends = malloc(lextcn);
	for(j = 0; j < lclassn; j++){
		nom[j] = yytext[j + cnstart];
	}
	for(j = 0; j < lextcn; j++){
		extends[j] = yytext[j + ecnstart];
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

{FUNCTION}+" "+{CONSTRUCTOR}+"("+{VARS}+")"     {
	printf(" * Constructor: %s\n", yytext);
	int i=13, varlen, j, endofvars = 0, varsn = 0;
	while(endofvars == 0) {
		if(yytext[i] == ')'){
			endofvars = 1;
			printf(" * * [ No. of vars parsed: %d ]\n", varsn);
			break;break;
		}
		for(j=i; j<yyleng; j++){
			if(yytext[j] == ',' || yytext[j] == ')'){
				varlen = j - i;
				varsn++;
				break;break;
			}
		}
		char *varname = malloc(varlen);
		for(j=0; j<varlen; j++){
			varname[j] = yytext[i + j];
		}
		printf(" * * Receives var: %s (of length %d / %d)\n", varname, varlen, strlen(varname));
		free(varname);
		i+= (varlen);
		if(yytext[i] == ',')
			i++;
		for(j=i;j<yyleng;j++){
			if(yytext[j] != ' '){
				i = j;
				break;break;
			}
		}
	}
	num_base_level = num_level;
	BEGIN(method);
}


{FUNCTION}+" "+{ALEVEL}+{FVNAME}+"("+{VARS}+")"     {
	int actpos = 4, j, fnleng, varlen, endofvars = 0, varsn = 0;
	for(j = actpos; j < yyleng; j++){
		if(yytext[j] == '('){
			fnleng = j - actpos;
			break; break;
		}
	}
	char *funcname = malloc(fnleng);
	for(j=0;j<fnleng;j++){
		funcname[j] = yytext[actpos + j];
	}
	printf(" * Function: %s (of length %d / %d)\n", funcname, fnleng, strlen(funcname));
	free(funcname);
	actpos += fnleng + 1;
	while(endofvars == 0) {
		if(yytext[actpos] == ')'){
			endofvars = 1;
			printf(" * * [ No. of vars parsed: %d ]\n", varsn);
			break;break;
		}
		for(j=actpos; j<yyleng; j++){
			if(yytext[j] == ',' || yytext[j] == ')'){
				varlen = j - actpos;
				varsn++;
				break;break;
			}
		}
		char *varname = malloc(varlen);
		for(j=0; j<varlen; j++){
			varname[j] = yytext[actpos + j];
		}
		printf(" * * Receives var: %s (of length %d / %d)\n", varname, varlen, strlen(varname));
		free(varname);
		actpos+= (varlen);
		if(yytext[actpos] == ',')
			actpos++;
		for(j=actpos;j<yyleng;j++){
			if(yytext[j] != ' '){
				actpos = j;
				break;break;
			}
		}
	}
	num_base_level = num_level;
	BEGIN(method);
}

.	{
	num_chars_current_line++;
}

%% 
main() 
{ 
  yylex(); 
  printf( "---\nParsed %d lines\nEnd of execution\n", num_lines); 
}
