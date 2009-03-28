%{ 
int num_lines = 0;
int num_level = 0;
int num_base_level = 0;
int num_chars_current_line = 0;
%} 

ALEVEL ""|"__"
CLASS "class"
FUNCTION "def"
CNAME [A-Z][a-zA-Z0-9_]*
FVNAME [a-z][a-zA-Z0-9_]*
EXTENDS ""|[A-Z][a-zA-Z0-9_]*
SLCOMMENT "#"
MLCOMMENT "'''"
VARS ""|([a-z][a-zA-Z0-9_]*[' ']*[',']?[' ']*)*([a-z][a-zA-Z0-9_]*[' ']*)?
CVARS [a-z][a-zA-Z0-9_]*
CONSTRUCTOR "__init__"
SPACES (\t|" ")*

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
}
.     {}
}
<slcomment>{
\n     {
	num_lines++;
	BEGIN(INITIAL);
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
		yyless(0);
		BEGIN(INITIAL);
	}
}
}

{CVARS}+{SPACES}+"="     {
	int j, varleng;
	char *varname = NULL;
	if(num_level > 0){
		for(j = yyleng - 2; j >= 0; j--){
			if(yytext[j] != ' '){
				varleng = j + 1;
				break;break;
			}
		}
		varname = malloc(varleng);
		for(j=0;j<varleng;j++){
			varname[j] = yytext[j];
		}
		printf(" * Found Var: %s (of length %d / %d)\n", varname, varleng, strlen(varname));
	}
	free(varname);
}


{CLASS}+" "+{SPACES}+{ALEVEL}+{CNAME}+{SPACES}+("("+{SPACES}+{EXTENDS}+{SPACES}+")")?     {
	int alevel = 0, exts=0, lclassn, lextcn;
	int cnstart, ecnstart, j, spaces = 0, nyyleng;
	char *nyytext = NULL;
	char *nom = NULL;
	char *extends = NULL;
	
	for(j = 6; j < yyleng; j++){
		if(yytext[j] == ' ')
			spaces++;
	}
	nyyleng = yyleng - spaces - 6;
	nyytext = malloc(nyyleng);
	
	for(j=6; j < yyleng; j++){
		int a = 0;
		if(yytext[j] != ' '){
			nyytext[a] = yytext[j];
			a++;
		}
	}
	printf("nyytext is: %s and nyyleng is: %d / %d\n", nyytext, nyyleng, strlen(nyytext));
	if(nyytext[0] == '_' && nyytext[1] == '_'){
		cnstart = 2;
		alevel = 1;
	} else {
		cnstart = 0;
	}
	for(j = cnstart; j < nyyleng; j++){
		if(nyytext[j] == '('){
			ecnstart = j + 1;
			exts = 1;
			break; break;
		}
	}
	if(exts == 0) {
		lextcn = 1;
		ecnstart = nyyleng + 1;
	}
	else
		lextcn = nyyleng - ecnstart - 1;
	lclassn = ecnstart - 1 - cnstart;
	
	nom = malloc(lclassn);
	extends = malloc(lextcn);
	for(j = 0; j < lclassn; j++){
		nom[j] = nyytext[j + cnstart];
	}
	for(j = 0; j < lextcn; j++){
		extends[j] = nyytext[j + ecnstart];
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
		
	free(nyytext);
	free(nom);
	free(extends);
}

{FUNCTION}+" "+{SPACES}+{ALEVEL}+{FVNAME}+{SPACES}+"("+{VARS}+")"     {
	int actpos = 4, j, fnleng, varlen, endofvars = 0, varsn = 0;
	char *funcname = NULL;
	char *varsna = NULL;
	for(j = actpos; j < yyleng; j++){
		if(yytext[j] == '('){
			fnleng = j - actpos;
			break; break;
		}
	}
	funcname = malloc(fnleng);
	for(j=0;j<fnleng;j++){
		funcname[j] = yytext[actpos + j];
	}
	if(strcmp(funcname,"__init__")==0)
		printf(" * Constructor: %s (of length %d / %d)\n", funcname, fnleng, strlen(funcname));
	else
		printf(" * Function: %s (of length %d / %d)\n", funcname, fnleng, strlen(funcname));
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
		varsna = malloc(varlen);
		for(j=0; j<varlen; j++){
			varsna[j] = yytext[actpos + j];
		}
		printf(" * * Receives var: %s (of length %d / %d)\n", varsna, varlen, strlen(varsna));
		free(varsna);
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
	free(funcname);
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
