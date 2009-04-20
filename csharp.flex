%{
/* Definicion de stacks por medio de una lista ligada */

struct Celda {
int valor;
struct Celda *siguiente;
};

struct ListaLigada {
struct Celda *primero;
int longitud;
};

struct ListaLigada *apila(int num, struct ListaLigada *lista) {
if(lista == NULL) {
lista = (struct ListaLigada *)malloc(sizeof(struct ListaLigada));
lista->primero = NULL;
lista->longitud = 0;
}
if(lista->primero == NULL) {
(lista->primero) = (struct Celda *)malloc(sizeof(struct Celda));
(lista->primero)->valor = num;
(lista->primero)->siguiente = NULL;
(lista->longitud)++;
} else {
struct Celda *temp = (struct Celda *)malloc(sizeof(struct Celda));
temp->valor = num;
temp->siguiente = lista->primero;
lista->primero = temp;
(lista->longitud)++;
}

return lista;
}

int desapila(struct ListaLigada *lista) {
int tope;
if(lista == NULL) {
lista = (struct ListaLigada *)malloc(sizeof(struct ListaLigada));
lista->primero = NULL;
lista->longitud = 0;
}
if(lista->primero == NULL) {
printf("Error, lista vacia.\n");
exit(0);
} else {
tope = lista->primero->valor;
lista->primero = lista->primero->siguiente;
(lista->longitud)--;
}
return tope;
}
%}

%{
/* Archivo con en el que sescribira el xml de la gerarquia de clases que se esta leyendo */
FILE *file;

/* Numero de lineas dle archivo */
int num_lines = 0;

/* Numero de corchetes que ayuda a saltar el contenido de los metodos */
int num_corchetes = 0;

/* Variable de apoyo para manejar comentarios anidados */
int comment_level = 0;

/* Variable que cuenta el numero de clases que llevamos leidas con respecto al numero de corchetes que han abierto y cerrado */
int not_end_class = 0;

/* Variable que decide si ya se leyo al menos una clase */
int start_class = 0;

/* Checa en el caso de que el archivo leido sea una interfaz, para asi cerrar con una etiqueta distinta */
int start_interface = 0;

/* Controla la apertura de clases anidadas */
struct ListaLigada *pila = NULL;

/* Lleva el conteo de los tabs que se deben de ir insertando segun el numero de clases anidadas que haya */
int num_tabs = 0;

/* Checa si un metodo es constructor o no */
int is_constructor = 0;

/* Las posibilidades de modificador de un atributo */
int is_static = 0, is_volatile = 0, is_transient= 0, is_final = 0;

/* Modificador de acceso y tipo del atributo actual */
char *atrib_mod, *atrib_type;

/* Apoyo para comer los comentarios dentro de la lectura de variables */
int start_vc = 0, start_var_cons = 0, start_var_sc = 0;

/* Apoyo para comerse los constructores dentro de los argumentos de un metodo */
int arg_cons = 0;
%}

%{
void printabs() {
int i = 0;
for(; i < num_tabs; i++)
fprintf(file, "\t");
}
%}

/*
* EXPRESIONES REGULARES PARA TODO EL LEXER
*/
PREPROCESSOR           ^[ \t]*#.*
SPACES (" "|\t)+
ALEVEL ("public"|"private"|"protected"|"internal"|"protected internal")
RETURN [.a-zA-Z0-9\[\]_]+
FINAL "sealed"
STATIC "static"
ABSTRACT "abstract"

/*
* EXPRESIONES REGULARES PARA LA DETECCION DE CLASES
*/
CLASS "class"
INTERFACE "interface"
NAMECLASS [A-Z][a-zA-Z0-9_]+
EXTENDS ":"
IMPLEMENTS "implements"

/*
* ESXPRESIONES IMPORT Y USING
*/
IMPORT "import"
NAMEIMPORT [a-zA-Z0-9.*_]+
USING "using"
NAMEUSING [a-zA-Z0-9._]+

/*
* EXPRESIONES REGULARES PARA DETECCION DE METODOS
*/
NATIVE "native"
SYNC "synchronized"
THROWS "throws"
NAMEMETHOD [a-z][a-zA-Z0-9_]+{SPACES}?"("

/*
* EXPRESIONES REGULARES PARA LA DETECCION CONTRUCTORES
*/
NAMECONTRUCTOR [A-Z][a-zA-Z0-9_]+{SPACES}?"("
/*
* EXPRESION QUE CASA EN NOMBRE DE METODOS
*/
NAMEVAR [a-zA-z0-9_]+

%x comment
%x comment_simple
%x interfaces
%x import
%x using
%x metodo
%x throws
%x variables
%x next_var
%x var_sc
%x var_c
%x var_string
%x var_cons
%x var_comment
%x var_simple_comment
%x arguments
%x next_argument
%x arg_constructor
%x arg_string
%x preprocessor
%%

"/*" { BEGIN(comment); comment_level = 1; }
<comment>{ /* Ignora los cometarios normales en java */
\n {num_lines++;}
"/*" {comment_level++;}
"*/" {
comment_level--;
if(comment_level == 0)
BEGIN(INITIAL);
}
. {}
}

"//" { BEGIN(comment_simple); }
<comment_simple>{ /* Ignora los comentarios simples en java */
\n {
num_lines++;
BEGIN(INITIAL);
}
. {}
}

\n { num_lines++; }

"{" { not_end_class++; }

"}" {
not_end_class--;
if(not_end_class == 0) {
num_tabs--;
if(start_interface) {
fprintf(file, "</interface>\n");
start_interface = 0;
} else {
printabs(); fprintf(file, "</class>\n");
if(pila != NULL)
if(pila->primero != NULL)
not_end_class = desapila(pila);
}
}
}


{PREPROCESSOR} { BEGIN(preprocessor); }
<preprocessor>{ /* Ayudara a ignorar los imports por preprocesador */
\n { num_lines++; }
{NAMEIMPORT} { printf("Import by preprocessor to : %s.\n", yytext); }
";" { BEGIN(INITIAL); }
. {}
}

{USING} { BEGIN(using); }
<using>{ /*ayudara a ignorar los using */
\n { num_lines++; }
{NAMEUSING} { printf("Is using in : %s.\n", yytext); }
";" { BEGIN(INITIAL); }
. {}
}

 /* Cachara el nombre de cada clase leida */
({ALEVEL}{SPACES})?(({ABSTRACT}|{FINAL}){SPACES})?{CLASS}{SPACES}{NAMECLASS} {
if(not_end_class > 0) {
pila = apila(not_end_class, pila);
not_end_class = 0;
}

if(start_class == 0) {
start_class = 1;
fprintf(file, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
}

printabs(); fprintf( file, "<class>\n");
num_tabs++;

int i = 0, j = 0, index = 0;
int num_args = 0, pw = 0;

char *accesmod = malloc(yyleng);
char *name = malloc(yyleng);
char *abstract = "abstract"; int abst = 0;
char *final = "final";

while(j < yyleng) {
i = 0;
while(yytext[j] != ' ' && yytext[j] != '\t') { j++; }
while(yytext[j] == ' ' || yytext[j] == '\t') { j++; i = 1; }
if(i == 1) { num_args++; }
}
num_args -= 1;

while(yytext[index] != ' ' && yytext[index] != '\t') { index++; }
for(j = 0; j < index; j++) { accesmod[j] = yytext[j]; } accesmod[j] = '\0';
switch(num_args) {
case 1: printabs(); fprintf(file, "<accesmod>protected</accesmod>\n"); break;
case 2:
switch(j) { //Si no tiene accesmod entonces vemos que sea abstract o final.
case 5 :
printabs(); fprintf(file, "<accesmod>protected</accesmod>\n");
printabs(); fprintf(file, "<final>TRUE</final>\n");
break;
case 8 :
printabs(); fprintf(file, "<accesmod>protected</accesmod>\n");
printabs(); fprintf(file, "<abstract>TRUE</abstract>\n");
break;
default : printabs(); fprintf(file, "<accesmod>%s</accesmod>\n", accesmod);
}
break;
case 3:
printabs(); fprintf(file, "<accesmod>%s</accesmod>\n", accesmod);
while(yytext[j] == ' ' || yytext[j] == '\t') { j++; }
i = j;
while(yytext[j] != ' ' && yytext[j] != '\t') { j++; }
switch(j-i) { //Si no tiene accesmod entonces vemos que sea abstract o final.
case 8 : printabs(); fprintf(file, "<abstract>TRUE</abstract>\n", accesmod); break;
default : printabs(); fprintf(file, "<final>TRUE</final>\n", accesmod); break;
}
break;
}

// Nombre de la variable
index = yyleng - 1;
while(yytext[index] != ' ' && yytext[index] != '\t') { index--; }
index++;
for(j = 0; index < yyleng; j++, index++) { name[j] = yytext[index]; } name[j] = '\0';
printabs(); fprintf(file, "<name>%s</name>\n", name);

free(accesmod);
free(name);
}

 /* Cacha el nombre de la clase que hereda la clase actual */
{EXTENDS}{SPACES}{NAMECLASS} {
char *name = malloc(yyleng);

int index, j ;

// Nombre de la clase padre
index = yyleng - 1;
while(yytext[index] != ' ' && yytext[index] != '\t') { index--; }
index++;
for(j = 0; index < yyleng; j++, index++) { name[j] = yytext[index]; } name[j] = '\0';
printabs(); fprintf(file, "<extends>%s</extends>\n", name);
}

 /* Cacha el nombre de las interfaces que implemeta la clase actual */
{IMPLEMENTS} { BEGIN(interfaces); }
<interfaces>{
\n { num_lines++; }
{NAMECLASS} { printabs(); fprintf(file, "<implements>%s</implements>\n", yytext); }
"{" { not_end_class++; BEGIN(INITIAL);}
. {}
}

 /* Cacha la declaracion de una interface */
({ALEVEL}{SPACES})?{INTERFACE}{SPACES}{NAMECLASS} {
// Indica el inicio de una interface
start_interface = 1;

char *name = malloc(yyleng);

int index, j;

// Escribe la clave estandar de XML si no se ha leido clase alguna anteriormente
if(start_class == 0) {
start_class = 1;
fprintf(file, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
}

// Nombre de la interface
index = yyleng - 1;
while(yytext[index] != ' ' && yytext[index] != '\t') { index--; }
index++;
for(j = 0; index < yyleng; j++, index++) { name[j] = yytext[index]; } name[j] = '\0';
printabs(); fprintf(file, "<interface>\n");
num_tabs++;
printabs(); fprintf(file, "<accesmod>public</accesmod>\n");
printabs(); fprintf(file, "<name>%s</name>\n", name);

free(name);
}




 /* Ignora el contenido de los metodos */
<metodo>{
\n {num_lines++;}
"{" {num_corchetes++;}
"}" {
num_corchetes--;
if(num_corchetes == 0) {
if(is_constructor) {
printabs(); fprintf(file, "</constructor>\n");
is_constructor = 0;
} else {
printabs(); fprintf(file, "</method>\n");
}
BEGIN(INITIAL);
}
}
. {}
}

 /* Cacha las excepciones del metodo que se esta leyendo */
<throws>{
{NAMECLASS} { printabs(); fprintf(file, "\t<throws>%s</throws>\n", yytext); }
";" {
if(is_constructor) {
printabs(); fprintf(file, "</constructor>\n");
is_constructor = 0;
} else {
printabs(); fprintf(file, "</method>\n");
}
BEGIN(INITIAL);
}
"{" {
num_corchetes++;
BEGIN(metodo);
}
. {}
}

 /* Cacha los constructores de una clase */
({ALEVEL}{SPACES})?{NAMECONTRUCTOR} {
is_constructor = 1;

int i, have_mod = 0, j = 0;

char *accesmod = malloc(yyleng);
char *name = malloc(yyleng);

while(yytext[j] != '(') { j++; }
j--;
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
for(; j > 0; j--) { if(yytext[j] == ' ' || yytext[j] == '\t') { have_mod = 1; break; } }

printabs(); fprintf(file, "<constructor>\n");

if(have_mod) {
j = 0;
while(yytext[j] != ' ' && yytext[j] != '\t') { j++; }
for(i = 0; i < j; i++) { accesmod[i] = yytext[i]; } accesmod[i] = '\0';
printabs(); fprintf(file, "\t<accesmod>%s</accesmod>\n", accesmod);
} else {
printabs(); fprintf(file, "\t<accesmod>protected</accesmod>\n");
}


// Nombre del constructor
while(yytext[j] != ' ' && yytext[j] != '\t' && j > 0) { j--; }
if(j > 0) { j++; }
for(i = j; yytext[i] != ' ' && yytext[i] != '\t' && yytext[i] != '('; i++) { name[i - j] = yytext[i]; } name[i - j] = '\0';
printabs(); fprintf(file, "\t<name>%s</name>\n", name);

free(accesmod);
free(name);

// Comienza a comer los argumentos y despues las excepciones
BEGIN(arguments);
}

 /* Cache la firma de un metodo que puede ser o no estatico*/
({ALEVEL}{SPACES})?({STATIC}{SPACES})?{RETURN}{SPACES}{NAMEMETHOD} {

char *accesmod = malloc(yyleng);
char *name = malloc(yyleng);
char *type_return = malloc(yyleng);

int i = 0, j = 0, num_args = 0;

while(yytext[j] != '(') {
i = 0;
while(yytext[j] != ' ' && yytext[j] != '\t' && yytext[j] != '(' ) { j++; }
while(yytext[j] == ' ' || yytext[j] == '\t') { j++; i = 1; }
if(i == 1) { num_args++; }
}
if(yytext[j-1] == ' ' || yytext[j-1] == '\t')
num_args -= 1;

printabs(); fprintf(file, "<method>\n");

switch(num_args) {
case 1 :
printabs(); fprintf(file, "\t<accesmod>protected</accesmod>\n");
break;
case 2 :
i = 0;
while(yytext[i] != ' ' && yytext[i] != '\t') { i++; }
if(i == 6 && yytext[0] == 's') {
printabs(); fprintf(file, "\t<accesmod>protected</accesmod>\n");
printabs(); fprintf(file, "\t<static>TRUE</static>\n");
} else {
for(j = 0; j < i; j++) { accesmod[j] = yytext[j]; } accesmod[j] = '\0';
printabs(); fprintf(file, "\t<accesmod>%s</accesmod>\n", accesmod);
}
break;
case 3 :
for(i = 0; yytext[i] != ' ' && yytext[i] != '\t'; i++) { accesmod[i] = yytext[i]; } accesmod[i] = '\0';
printabs(); fprintf(file, "\t<accesmod>%s</accesmod>\n", accesmod);
printabs(); fprintf(file, "\t<static>TRUE</static>\n");
break;
}

// Nombre del metodo
while(yytext[j] != '(') { j++; }
j--;
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
while(yytext[j] != ' ' && yytext[j] != '\t' && j > 0) { j--; }
if(j > 0) { j++; }
for(i = j; yytext[i] != ' ' && yytext[i] != '\t' && yytext[i] != '('; i++) { name[i - j] = yytext[i]; } name[i - j] = '\0';

// Tipo de retorno del metodo
j--;
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
while(yytext[j] != ' ' && yytext[j] != '\t' && j > 0) { j--; }
if(j > 0) { j++; }
for(i = j; yytext[i] != ' ' && yytext[i] != '\t' && yytext[i] != '('; i++) { type_return[i - j] = yytext[i]; } type_return[i - j] = '\0';

printabs(); fprintf(file, "\t<return>%s</return>\n", type_return);
printabs(); fprintf(file, "\t<name>%s</name>\n", name);

// Checamos todos los argumentos que recibe este metodo ademas de las excepciones e ignorar el contenido del metodo
BEGIN(arguments);
}

 /* Cache la firma de un metodo que puede ser o no estatico, ademas de que es abstract o final*/
({ALEVEL}{SPACES})?({STATIC}{SPACES})?({ABSTRACT}|{FINAL}){SPACES}{RETURN}{SPACES}{NAMEMETHOD} {

char *accesmod = malloc(yyleng);
char *name = malloc(yyleng);
char *type_return = malloc(yyleng);

int i = 0, j = 0, num_args = 0;

while(yytext[j] != '(') {
i = 0;
while(yytext[j] != ' ' && yytext[j] != '\t' && yytext[j] != '(' ) { j++; }
while(yytext[j] == ' ' || yytext[j] == '\t') { j++; i = 1; }
if(i == 1) { num_args++; }
}
if(yytext[j-1] == ' ' || yytext[j-1] == '\t')
num_args -= 1;

printabs(); fprintf(file, "<method>\n");

switch(num_args) {
case 2 :
printabs(); fprintf(file, "\t<accesmod>protected</accesmod>\n");
break;
case 3 :
i = 0;
if(yytext[0] == 's') {
printabs(); fprintf(file, "\t<accesmod>protected</accesmod>\n");
printabs(); fprintf(file, "\t<static>TRUE</static>\n");
} else {
while(yytext[i] != ' ' && yytext[i] != '\t') { i++; }
for(j = 0; j < i; j++) { accesmod[j] = yytext[j]; } accesmod[j] = '\0';
printabs(); fprintf(file, "\t<accesmod>%s</accesmod>\n", accesmod);
}
break;
case 4 :
for(i = 0; yytext[i] != ' ' && yytext[i] != '\t'; i++) { accesmod[i] = yytext[i]; } accesmod[i] = '\0';
printabs(); fprintf(file, "\t<accesmod>%s</accesmod>\n", accesmod);
printabs(); fprintf(file, "\t<static>TRUE</static>\n");
break;
}

// Nombre del metodo
while(yytext[j] != '(') { j++; }
j--;
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
while(yytext[j] != ' ' && yytext[j] != '\t' && j > 0) { j--; }
if(j > 0) { j++; }
for(i = j; yytext[i] != ' ' && yytext[i] != '\t' && yytext[i] != '('; i++) { name[i - j] = yytext[i]; } name[i - j] = '\0';

// Tipo de retorno del metodo
j--;
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
while(yytext[j] != ' ' && yytext[j] != '\t' && j > 0) { j--; }
if(j > 0) { j++; }
for(i = j; yytext[i] != ' ' && yytext[i] != '\t' && yytext[i] != '('; i++) { type_return[i - j] = yytext[i]; } type_return[i - j] = '\0';

// Decidimos si es abstrac o final
j--;
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
if(yytext[j] == 'l') {
printabs(); fprintf(file, "\t<final>TRUE</final>\n");
} else {
printabs(); fprintf(file, "\t<abstract>TRUE</abstract>\n");
}

printabs(); fprintf(file, "\t<return>%s</return>\n", type_return);
printabs(); fprintf(file, "\t<name>%s</name>\n", name);

// Checamos todos los argumentos que recibe este metodo ademas de las excepciones e ignorar el contenido del metodo
BEGIN(arguments);
}

 /* Cache la firma de un metodo que puede ser o no estatico, ademas de que es synchronized*/
({ALEVEL}{SPACES})?({STATIC}{SPACES})?({SYNC}){SPACES}{RETURN}{SPACES}{NAMEMETHOD} {

char *accesmod = malloc(yyleng);
char *name = malloc(yyleng);
char *type_return = malloc(yyleng);

int i = 0, j = 0, num_args = 0;

while(yytext[j] != '(') {
i = 0;
while(yytext[j] != ' ' && yytext[j] != '\t' && yytext[j] != '(' ) { j++; }
while(yytext[j] == ' ' || yytext[j] == '\t') { j++; i = 1; }
if(i == 1) { num_args++; }
}
if(yytext[j-1] == ' ' || yytext[j-1] == '\t')
num_args -= 1;

printabs(); fprintf(file, "<method>\n");

switch(num_args) {
case 2 :
printabs(); fprintf(file, "\t<accesmod>protected</accesmod>\n");
break;
case 3 :
i = 0;
if(yytext[0] == 's') {
printabs(); fprintf(file, "\t<accesmod>protected</accesmod>\n");
printabs(); fprintf(file, "\t<static>TRUE</static>\n");
} else {
while(yytext[i] != ' ' && yytext[i] != '\t') { i++; }
for(j = 0; j < i; j++) { accesmod[j] = yytext[j]; } accesmod[j] = '\0';
printabs(); fprintf(file, "\t<accesmod>%s</accesmod>\n", accesmod);
}
break;
case 4 :
for(i = 0; yytext[i] != ' ' && yytext[i] != '\t'; i++) { accesmod[i] = yytext[i]; } accesmod[i] = '\0';
printabs(); fprintf(file, "\t<accesmod>%s</accesmod>\n", accesmod);
printabs(); fprintf(file, "\t<static>TRUE</static>\n");
break;
}

// Nombre del metodo
while(yytext[j] != '(') { j++; }
j--;
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
while(yytext[j] != ' ' && yytext[j] != '\t' && j > 0) { j--; }
if(j > 0) { j++; }
for(i = j; yytext[i] != ' ' && yytext[i] != '\t' && yytext[i] != '('; i++) { name[i - j] = yytext[i]; } name[i - j] = '\0';

// Tipo de retorno del metodo
j--;
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
while(yytext[j] != ' ' && yytext[j] != '\t' && j > 0) { j--; }
if(j > 0) { j++; }
for(i = j; yytext[i] != ' ' && yytext[i] != '\t' && yytext[i] != '('; i++) { type_return[i - j] = yytext[i]; } type_return[i - j] = '\0';

printabs(); fprintf(file, "\t<synchronized>TRUE</synchronized>\n");
printabs(); fprintf(file, "\t<return>%s</return>\n", type_return);
printabs(); fprintf(file, "\t<name>%s</name>\n", name);


// Checamos todos los argumentos que recibe este metodo ademas de las excepciones e ignorar el contenido del metodo
BEGIN(arguments);
}
 
 /* Cache la firma de un metodo que puede ser o no estatico, ademas de que es abstract o final*/
({ALEVEL}{SPACES})?({STATIC}{SPACES})?({ABSTRACT}|{FINAL}){SPACES}{SYNC}{SPACES}{RETURN}{SPACES}{NAMEMETHOD} {

char *accesmod = malloc(yyleng);
char *name = malloc(yyleng);
char *type_return = malloc(yyleng);

int i = 0, j = 0, num_args = 0;

while(yytext[j] != '(') {
i = 0;
while(yytext[j] != ' ' && yytext[j] != '\t' && yytext[j] != '(' ) { j++; }
while(yytext[j] == ' ' || yytext[j] == '\t') { j++; i = 1; }
if(i == 1) { num_args++; }
}
if(yytext[j-1] == ' ' || yytext[j-1] == '\t')
num_args -= 1;

printabs(); fprintf(file, "<method>\n");

switch(num_args) {
case 3 :
printabs(); fprintf(file, "\t<accesmod>protected</accesmod>\n");
break;
case 4 :
i = 0;
if(yytext[0] == 's') {
printabs(); fprintf(file, "\t<accesmod>protected</accesmod>\n");
printabs(); fprintf(file, "\t<static>TRUE</static>\n");
} else {
while(yytext[i] != ' ' && yytext[i] != '\t') { i++; }
for(j = 0; j < i; j++) { accesmod[j] = yytext[j]; } accesmod[j] = '\0';
printabs(); fprintf(file, "\t<accesmod>%s</accesmod>\n", accesmod);
}
break;
case 5 :
for(i = 0; yytext[i] != ' ' && yytext[i] != '\t'; i++) { accesmod[i] = yytext[i]; } accesmod[i] = '\0';
printabs(); fprintf(file, "\t<accesmod>%s</accesmod>\n", accesmod);
printabs(); fprintf(file, "\t<static>TRUE</static>\n");
break;
}

// Nombre del metodo
while(yytext[j] != '(') { j++; }
j--;
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
while(yytext[j] != ' ' && yytext[j] != '\t' && j > 0) { j--; }
if(j > 0) { j++; }
for(i = j; yytext[i] != ' ' && yytext[i] != '\t' && yytext[i] != '('; i++) { name[i - j] = yytext[i]; } name[i - j] = '\0';

// Tipo de retorno del metodo
j--;
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
while(yytext[j] != ' ' && yytext[j] != '\t' && j > 0) { j--; }
if(j > 0) { j++; }
for(i = j; yytext[i] != ' ' && yytext[i] != '\t' && yytext[i] != '('; i++) { type_return[i - j] = yytext[i]; } type_return[i - j] = '\0';

// Decidimos si es abstrac o final
j--;
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
while(yytext[j] != ' ' && yytext[j] != '\t') { j--; }
while(yytext[j] ==' ' || yytext[j] == '\t') { j--; }
if(yytext[j] == 'l') {
printabs(); fprintf(file, "\t<final>TRUE</final>\n");
} else {
printabs(); fprintf(file, "\t<abstract>TRUE</abstract>\n");
}

printabs(); fprintf(file, "\t<synchronized>TRUE</synchronized>\n");
printabs(); fprintf(file, "\t<return>%s</return>\n", type_return);
printabs(); fprintf(file, "\t<name>%s</name>\n", name);

// Checamos todos los argumentos que recibe este metodo ademas de las excepciones e ignorar el contenido del metodo
BEGIN(arguments);
}






<arguments>{
\n { num_lines++; }
{RETURN}{SPACES}{NAMEVAR} {
int i = 0, j = 0;

char *var_type = malloc(yyleng);
char *var_name = malloc(yyleng);

printabs(); fprintf(file, "\t<argument>\n");

// Tipo del argumento
for(j = 0; yytext[j]!=' ' && yytext[j]!='\t'; j++) { var_type[j] = yytext[j]; } var_type[j] = '\0';
printabs(); fprintf(file, "\t\t<type>%s</type>\n", var_type);

// Nombre del argumento
while(yytext[j] == ' ' || yytext[j] == '\t') { j++; }
for(i = 0; j < yyleng; i++, j++) { var_name[i] = yytext[j]; } var_name[i] = '\0';
printabs(); fprintf(file, "\t\t<name>%s</name>\n", var_name);

printabs(); fprintf(file, "\t</argument>\n");

// Avanzamos hasta encontrar el siguiente argumento o hasta el fin del metodo
BEGIN(next_argument);
}
")" {
BEGIN(throws);
}
. {}
}

<next_argument>{
\n { num_lines++; }
"(" {
arg_cons = 1;
BEGIN(arg_constructor);
}
"\"" {
BEGIN(arg_string);
}
"," {

BEGIN(arguments);
}
")" {
BEGIN(throws);
}
. {}
}

<arg_constructor>{
\n { num_lines++; }
"\"" {
BEGIN(arg_string);
}
"(" {
arg_cons++;
}
")" {
arg_cons--;
if(arg_cons == 0)
BEGIN(next_argument);
}
. {}
}

<arg_string>{
\n { num_lines++; }
"\"". {}
"\"" {
if(arg_cons == 0)
BEGIN(arguments);
else
BEGIN(arg_constructor);
}
. {}
}







<var_simple_comment>{
\n {
num_lines++;
BEGIN(variables);
}
. {}
}

<var_comment>{
\n { num_lines++; }
"/*" {
start_var_sc++;
}
"*/" {
start_var_sc--;
if(start_var_sc == 0)
BEGIN(variables);
}
. {}
}

 /* Cacha el nombre de todas las variables que tienen en comun el tipo y demas caracterirsticas */
<variables>{
\n { num_lines++; }
{NAMEVAR} {
printabs(); fprintf(file, "<var>\n");
printabs(); fprintf(file, "\t<accesmod>%s</accesmod>\n", atrib_mod);
if(is_static) {
printabs(); fprintf(file, "\t<static>TRUE</static>\n");
}
if(is_final) {
printabs(); fprintf(file, "\t<final>TRUE</final>\n");
}
if(is_transient) {
printabs(); fprintf(file, "\t<transient>TRUE</transient>\n");
}
if(is_volatile) {
printabs(); fprintf(file, "\t<volatile>TRUE</volatile>\n");
}
printabs(); fprintf(file, "\t<type>%s</type>\n", atrib_type);
printabs(); fprintf(file, "\t<name>%s</name>\n", yytext);
printabs(); fprintf(file, "</var>\n");
BEGIN(next_var);
}
"//" {
BEGIN(var_simple_comment);
}
"/*" {
start_var_sc = 1;
BEGIN(var_comment);
}
. {}
}


<var_sc>{
\n {
num_lines++;
BEGIN(next_var);
}
. {}
}

<var_c>{
\n { num_lines++; }
"/*" { start_vc++; }
"*/" {
start_vc--;
if(start_vc == 0)
BEGIN(next_var);
}
. {}
}

<var_string>{
\n { num_lines++; }
"\\". {}
"\"" {
if(start_var_cons == 0)
BEGIN(next_var);
else
BEGIN(var_cons);
}
. {}
}

<var_cons>{
\n { num_lines++; }
"(" {
start_var_cons++;
}
")" {
start_var_cons--;
if(start_var_cons == 0)
BEGIN(next_var);
}
"\"" {
BEGIN(var_string);
}
. {}
}

<next_var>{
\n {num_lines++; }
"," {
BEGIN(variables);
}
";" {
is_static = 0;
is_final = 0;
is_transient = 0;
is_volatile = 0;
BEGIN(INITIAL);
}
"//" { BEGIN(var_sc); }
"/*" {
start_vc = 1;
BEGIN(var_c);
}
"\"" {
BEGIN(var_string);
}
"(" {
start_var_cons = 1;
BEGIN(var_cons);
}
. {}
}

 /* Cacha el inicio de la declaracion de un atributo de clase, se iniciara una semi rutina que leera el nombre de cada variable */
({ALEVEL}{SPACES})?({STATIC}{SPACES})?({FINAL}{SPACES})?{RETURN} {
int i = 0, j = 0, num_args = 0;

atrib_mod = malloc(yyleng);
atrib_type = malloc(yyleng);

char *statico ="static";
char *final = "final";

while(j < yyleng) {
i = 0;
while(yytext[j] != ' ' && yytext[j] != '\t') { j++; }
while(yytext[j] == ' ' || yytext[j] == '\t') { j++; i = 1; }
if(i == 1) { num_args++; }
} num_args--;

switch(num_args) {
case 0:
atrib_mod = "protected";
for(i = 0; i < yyleng; i++) { atrib_type[i] = yytext[i]; } atrib_type[i] = '\0';
break;
case 1:
if(yytext[0] == 's') {
is_static = 1;
atrib_mod = "protected";
} else if(yytext[0] == 'f') {
is_final = 1;
atrib_mod = "protected";
} else {
i = 0;
while(yytext[i] != ' ' && yytext[i] != '\t') { i++; }
switch(i) {
case 6 : atrib_mod = "public"; break;
case 7 : atrib_mod = "private"; break;
case 9 : atrib_mod = "protected"; break;
}
}
break;
case 2:
if(yytext[0] == 'p') {
for(i = 0; yytext[i] != ' ' && yytext[i] != '\t'; i++)
atrib_mod[i] = yytext[i];
while(yytext[i] == ' ' || yytext[i] == '\t')
i++;
if(yytext[i] == 's')
is_static = 1;
else if(yytext[i] == 'f')
is_final = 1;
} else {
is_final = 1;
is_static = 1;
atrib_mod = "protected";
}

break;
case 3:
is_static = 1;
is_final = 1;

// Modificador de acceso del atributo actual
for(i = 0; yytext[i] != ' ' && yytext[i] != '\t'; i++) { atrib_mod[i] = yytext[i]; } atrib_mod[i] = '\0';

break;
}

// Tipo del atributo actual
i = yyleng-1;
while(yytext[i] != ' ' && yytext[i] != '\t') { i--; } i += 1;
for(j = i; j < yyleng; j++) { atrib_type[j - i] = yytext[j]; } atrib_type[j - i] = '\0';

// Comenzamos a leer todas las variables con mismo tipo
BEGIN(variables);
}

. {} /* Cacha lo que sea que no este contemplado dentro de la sintaxis del lenguaje */

%%
main() {
file = fopen("Pedro.java.xml","w");
if(file == NULL) { printf("No mames ahora que chingados paso.\n"); }
yylex();
fclose(file);
printf("Fin de la ejecucion, se leyeron %d lineas.\n", num_lines);
}

int yywrap() {
return 1;
}