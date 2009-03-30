%{

FILE *f;

int num_lines = 0;
int num_level = 0;
int num_base_level = 0;
int num_chars_current_line = 0;
int opened_class = 0;
%} 

ALEVEL ""|"__"
CLASS "class"
FUNCTION "def"
CNAME [A-Z][a-zA-Z0-9_]*
FVNAME [a-z_][a-zA-Z0-9_]*
EXTENDS ""|[A-Z][a-zA-Z0-9_]*
SLCOMMENT "#"
MLCOMMENT "'''"
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
				varleng = j + 2;
				break;break;
			}
		}
		varname = malloc(varleng);
		for(j=0;j<varleng;j++){
			varname[j] = yytext[j];
		}
		varname[varleng-1] = '\0';
		fprintf(f,"\t<var>\n");
		fprintf(f,"\t\t<name> %s </name>\n", varname);
		fprintf(f,"\t\t<type> VOID </type>\n");
		fprintf(f,"\t</var>\n");
		free(varname);
	}
}


{CLASS}+" "+{SPACES}+{ALEVEL}+{CNAME}+{SPACES}+("("+{SPACES}+{EXTENDS}+{SPACES}+")")?     {
	if(opened_class == 1)
		fprintf(f,"</class>\n");
	else
		fprintf(f,"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
	
	int alevel = 0, exts=0, lclassn, lextcn;
	int cnstart, ecnstart, j, spaces = 0, nyyleng;
	int a = 0;
	char *nyytext = NULL;
	char *nom = NULL;
	char *extends = NULL;
	
	for(j = 6; j < yyleng; j++){
		if(yytext[j] == ' ')
			spaces++;
	}
	nyyleng = yyleng - spaces - 6 + 1;
	nyytext = malloc(nyyleng);
	
	for(j=6; j < yyleng; j++){
		if(yytext[j] != ' '){
			nyytext[a] = yytext[j];
			a++;
		}
	}
	nyytext[nyyleng - 1] = '\0';
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
	lclassn = ecnstart - cnstart;
	
	nom = malloc(lclassn);
	extends = malloc(lextcn);
	for(j = 0; j < lclassn; j++){
		nom[j] = nyytext[j + cnstart];
	}
	nom[lclassn - 1] = '\0';
	for(j = 0; j < lextcn; j++){
		extends[j] = nyytext[j + ecnstart];
	}
	extends[lextcn - 1] = '\0';
	
	fprintf(f,"<class>\n\t<name> %s </name>\n", nom);
	if(exts==0 || lextcn == 1)
		fprintf(f,"\t<extends> object </extends>\n");
	else
		fprintf(f,"\t<extends> %s </extends>\n", extends);
	if(alevel == 1)
		fprintf(f,"\t<accmod> private </accmod>\n");
	else
		fprintf(f,"\t<accmod> public </accmod>\n");
		
	free(nyytext);
	free(nom);
	free(extends);
	
	opened_class = 1;
}

{FUNCTION}+" "+{SPACES}+{ALEVEL}+{FVNAME}+{SPACES}+"("+(.*)+")"     {
	int actpos = 0, j, fnleng, varlen, endofvars = 0, varsn = 0, nyyleng;
	int a = 0, spaces = 0;
	char *nyytext = NULL;
	char *funcname = NULL;
	char *varsna = NULL;
	
	for(j = 4; j < yyleng; j++){
		if(yytext[j] == ' ')
			spaces++;
	}
	nyyleng = yyleng - spaces - 4 + 1;
	nyytext = malloc(nyyleng);
	
	for(j=4; j < yyleng; j++){
		if(yytext[j] != ' '){
			nyytext[a] = yytext[j];
			a++;
		}
	}
	nyytext[nyyleng - 1] = '\0';
	
	
	for(j = actpos; j < nyyleng; j++){
		if(nyytext[j] == '('){
			fnleng = j - actpos + 1;
			break; break;
		}
	}
	funcname = malloc(fnleng);
	for(j=0;j<fnleng;j++){
		funcname[j] = nyytext[actpos + j];
	}
	funcname[fnleng - 1] = '\0';
	
	fprintf(f,"\t<method>\n");
	
	if(strcmp(funcname,"__init__")==0)
		fprintf(f,"\t\t<constructor> true </constructor>\n");
	fprintf(f,"\t\t<name> %s </name>\n", funcname);
	fprintf(f,"\t\t<type> Undefined </type>\n");
	actpos += fnleng;
	fprintf(f,"\t\t<receives>\n");
	while(endofvars == 0) {
		if(nyytext[actpos] == ')'){
			endofvars = 1;
			fprintf(f,"\t\t</receives>\n");
			break;break;
		}
		for(j=actpos; j<nyyleng; j++){
			if(nyytext[j] == ',' || nyytext[j] == ')'){
				varlen = j - actpos + 1;
				varsn++;
				break;break;
			}
		}
		varsna = malloc(varlen);
		for(j=0; j<varlen; j++){
			varsna[j] = nyytext[actpos + j];
		}
		varsna[varlen - 1] = '\0';
		fprintf(f,"\t\t\t<var>\n");
		fprintf(f,"\t\t\t\t<name> %s </name>\n", varsna);
		fprintf(f,"\t\t\t\t<type> VOID </type>\n");
		fprintf(f,"\t\t\t</var>\n");
		free(varsna);
		actpos += varlen - 1;
		if(nyytext[actpos] == ',')
			actpos++;
	}
	free(funcname);

	fprintf(f,"\t</method>\n");
	num_base_level = num_level;
	BEGIN(method);
}

.	{
	num_chars_current_line++;
}

%%

main(){ 
	f = fopen("prueba.py.xml","w");
	yylex();
	if(opened_class == 1){
		fprintf(f,"</class>\n");
	}
  	fclose(f);
  	printf( "---\nParsed %d lines\nEnd of execution\n", num_lines); 
}
