%{

FILE *f;

int num_lines = 0;
int num_level = 0;
int num_base_level = 0;
int num_chars_current_line = 0;
int opened_class = 0;
int opened_method = 0;
int started = 0;

%} 
%{
	void ptabs(int num) {
		int i;
		for(i = 0; i < num; i++)
			fprintf(f, "\t");	
	}
%}

AMOD ["__"]?
CLASS "class"
FUNCTION "def"
CNAME [A-Z][a-zA-Z0-9_]*
FVNAME [a-z_][a-zA-Z0-9_]*
EXTENDS ([A-Z][a-zA-Z0-9_]*)?
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

{MLCOMMENT} {
	if(opened_class > 0){
		ptabs(opened_class);
		fprintf(f,"<mlcomment>\n");
		ptabs(opened_class);
	}
	BEGIN(mlcomment); 
}
{SLCOMMENT}     {
	if(opened_class > 0){
		ptabs(opened_class);
		fprintf(f,"<slcomment>\n");
		ptabs(opened_class);
	}
	BEGIN(slcomment);
}

<mlcomment>{
\n     {
	num_lines++;
	if(opened_class > 0){
		fprintf(f,"\n");
		ptabs(num_base_level + 1);
	}
}
{MLCOMMENT}     {
	if(opened_class > 0){
		fprintf(f,"\n");
		ptabs(opened_class);
		fprintf(f,"</mlcomment>\n");
	}
	BEGIN(INITIAL);
}
.     {
	if(opened_class > 0)
		fprintf(f,"%s", yytext);
}
}

<slcomment>{
\n     {
	num_lines++;
	if(opened_class > 0){
		fprintf(f,"\n");
		ptabs(opened_class);
		fprintf(f,"</slcomment>\n");
	}
	BEGIN(INITIAL);
}
.     {
	if(opened_class > 0)
		fprintf(f,"%s", yytext);
}
}

<method>{
\n     {
	num_lines++;
	num_level=0;
	num_chars_current_line = 0;
	fprintf(f,"\n");
	ptabs(num_base_level + 1);
}

\t     {
	if(num_chars_current_line == 0)
		num_level++;
	else
		fprintf(f,"\t");
}
" "     {
	if(num_chars_current_line == 0)
		num_level++;
	fprintf(f," ");
}

":"     {}

.		{
	if(num_level <= num_base_level) {
		yyless(0);
		fprintf(f,"\t\t</content>\n");
		fprintf(f,"\t</method>\n");
		opened_method = 0;
		BEGIN(INITIAL);
	}
	fprintf(f,"%s", yytext);
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
		varname = malloc(sizeof(char)*varleng);
		for(j=0;j<varleng;j++){
			varname[j] = yytext[j];
		}
		varname[varleng-1] = '\0';
		ptabs(opened_class);
		fprintf(f,"<var>\n");
		ptabs(opened_class+1);
		fprintf(f,"<name> %s </name>\n", varname);
		ptabs(opened_class+1);
		fprintf(f,"<type> VOID </type>\n");
		ptabs(opened_class);
		fprintf(f,"</var>\n");
		free(varname);
	}
}


{CLASS}+" "+{SPACES}+{AMOD}+{CNAME}+{SPACES}+("("+{SPACES}+{EXTENDS}+{SPACES}+")")?     {
	int m;
	if(opened_class > 0){
		if(num_level >= opened_class){
			opened_class++;
		} else {
			for(m=0; m < opened_class - num_level; m++){
				fprintf(f,"</class>\n");
			}
			opened_class = num_level + 1;
		}
	} else {
		if(started == 0){
			fprintf(f,"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
			started = 1;
		}
		opened_class++;
	}
	
	int amod = 0, exts=0, lclassn, lextcn;
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
	nyytext = malloc(sizeof(char)*nyyleng);
	
	for(j=6; j < yyleng; j++){
		if(yytext[j] != ' '){
			nyytext[a] = yytext[j];
			a++;
		}
	}
	nyytext[nyyleng - 1] = '\0';
	if(nyytext[0] == '_' && nyytext[1] == '_'){
		cnstart = 2;
		amod = 1;
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
	
	nom = malloc(sizeof(char)*lclassn);
	extends = malloc(sizeof(char)*lextcn);
	for(j = 0; j < lclassn; j++){
		nom[j] = nyytext[j + cnstart];
	}
	nom[lclassn - 1] = '\0';
	for(j = 0; j < lextcn; j++){
		extends[j] = nyytext[j + ecnstart];
	}
	extends[lextcn - 1] = '\0';
	ptabs(opened_class-1);
	fprintf(f,"<class>\n");
	ptabs(opened_class);
	fprintf(f,"<name> %s </name>\n", nom);
	ptabs(opened_class);
	if(exts==0 || lextcn == 1)
		fprintf(f,"<extends> object </extends>\n");
	else
		fprintf(f,"<extends> %s </extends>\n", extends);
	ptabs(opened_class);
	if(amod == 1)
		fprintf(f,"<accmod> private </accmod>\n");
	else
		fprintf(f,"<accmod> public </accmod>\n");
		
	free(nyytext);
	free(nom);
	free(extends);
}

{FUNCTION}+" "+{SPACES}+{AMOD}+{FVNAME}+{SPACES}+"("+(.*)+")"     {
	int actpos = 0, j, fnleng, varlen, endofvars = 0, varsn = 0, nyyleng, amod = 0;
	int a = 0, spaces = 0;
	char *nyytext = NULL;
	char *funcname = NULL;
	char *varsna = NULL;
	
	for(j = 4; j < yyleng; j++){
		if(yytext[j] == ' ')
			spaces++;
	}
	nyyleng = yyleng - spaces - 4 + 1;
	nyytext = malloc(sizeof(char)*nyyleng);
	
	for(j=4; j < yyleng; j++){
		if(yytext[j] != ' '){
			nyytext[a] = yytext[j];
			a++;
		}
	}
	nyytext[nyyleng - 1] = '\0';
	
	if(nyytext[0] == '_' && nyytext[1] == '_'){
		actpos = 2;
		amod = 1;
	} else {
		actpos = 0;
	}
	
	for(j = actpos; j < nyyleng; j++){
		if(nyytext[j] == '('){
			fnleng = j - actpos + 1;
			break; break;
		}
	}
	funcname = malloc(sizeof(char)*fnleng);
	for(j=0;j<fnleng;j++){
		funcname[j] = nyytext[actpos + j];
	}
	funcname[fnleng - 1] = '\0';
	
	ptabs(opened_class);
	fprintf(f,"<method>\n");
	
	if(strcmp(funcname,"init__")==0){
		ptabs(opened_class+1);
		fprintf(f,"<constructor> true </constructor>\n");
	}
	ptabs(opened_class+1);
	fprintf(f,"<name> %s </name>\n", funcname);
	ptabs(opened_class+1);
	fprintf(f,"<type> Undefined </type>\n");
	ptabs(opened_class+1);
	if(amod == 1)
		fprintf(f,"<accmod> private </accmod>\n");
	else
		fprintf(f,"<accmod> public </accmod>\n");
	
	actpos += fnleng;
	ptabs(opened_class+1);
	fprintf(f,"<receives>\n");
	while(endofvars == 0) {
		if(nyytext[actpos] == ')'){
			endofvars = 1;
			ptabs(opened_class+1);
			fprintf(f,"</receives>\n");
			break;break;
		}
		for(j=actpos; j<nyyleng; j++){
			if(nyytext[j] == ',' || nyytext[j] == ')'){
				varlen = j - actpos + 1;
				varsn++;
				break;break;
			}
		}
		varsna = malloc(sizeof(char)*varlen);
		for(j=0; j<varlen; j++){
			varsna[j] = nyytext[actpos + j];
		}
		varsna[varlen - 1] = '\0';
		ptabs(opened_class+2);
		fprintf(f,"<var>\n");
		ptabs(opened_class+3);
		fprintf(f,"<name> %s </name>\n", varsna);
		ptabs(opened_class+3);
		fprintf(f,"<type> VOID </type>\n");
		ptabs(opened_class+2);
		fprintf(f,"</var>\n");
		free(varsna);
		actpos += varlen - 1;
		if(nyytext[actpos] == ',')
			actpos++;
	}
	free(funcname);

	num_base_level = num_level;
	ptabs(opened_class+1);
	fprintf(f,"<content>\n");
	opened_method = 1;
	BEGIN(method);
}

.	{
	num_chars_current_line++;
}

%%

int main(int argc, char* argv[]){
	int m;
	char* newname = strcat(argv[1], ".xml");
	f = fopen(newname,"w");
	yylex();
	if(opened_method == 1){
		fprintf(f,"\t\t</content>\n");
		fprintf(f,"\t</method>\n");
	}
	if(opened_class > 0){
		for(m=0; m < opened_class; m++){
			fprintf(f,"</class>\n");
		}
	}
  	fclose(f);
  	printf( "---\nParsed %d lines\nEnd of execution\n", num_lines); 
}
