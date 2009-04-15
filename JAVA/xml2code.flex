%{
#include <string.h>

struct node {
	char *line;
	struct node *next;
};

struct Stack {
	struct node *first;
	int length;
};

struct Stack *push(struct Stack *list, char *text) {
		if(list == NULL) {
			list = (struct Stack *)malloc(sizeof(struct Stack));
			list -> first = NULL;
			list -> length = 0;
		}

		char *ttext = NULL;
		ttext = (char *)malloc(sizeof(char)*strlen(text)+ 1);
		strcpy(ttext,text);

		if(list -> first == NULL){
			(list -> first) = (struct node *)malloc(sizeof(struct node));
			(list -> first) -> line = ttext;
			(list -> first) -> next = NULL;
			(list -> length) = 1;
		} else {
			struct node *temp = (struct node *)malloc(sizeof(struct node));
			temp -> line = ttext;
			temp -> next = list -> first;
			list -> first = temp;
			(list -> length)++;
		}
	return list;
}

char *pop(struct Stack *list) {
	char *temp;
	temp = (char *)malloc(sizeof(char)*strlen(list -> first -> line)+ 1);
		if(list == NULL) {
			list = (struct Stack *)malloc(sizeof(struct Stack));
			list -> first = NULL;
			list -> length = 0;
		}
		if(list -> first == NULL){
			printf("Error,empty stack.\n");
			exit(0);
		} else {
			temp = list -> first -> line;
			list -> first = list -> first -> next;
			(list -> length)--;
		}
	return temp;
}
%}

%{
	/* Archivo en el cual se escribe actualmente */	
	FILE *file;

	/* Checamos el nivle de indentacion en el que estasmo parados */
	int tabs = 0;

	/* Sirve para checar si una clase ha empezado y si ya se ha escrito el codigo correspondiente */
	int load_class = 0;

	/* Atributos de clase */
	int is_interface = 0;
	char *class_accesmod, *class_name;
	int class_abstract = 0, class_final = 0;
	int class_implements = 0, class_extends = 0;
	char *class_super;
	struct Stack *interfaces = NULL;	

	/* Atributos de un metodo */
	int is_constructor = 0;
	int method_abstract = 0, method_final = 0;
	char *method_return, *method_name, *method_accesmod;
	int method_synchronized = 0, method_static = 0;
	int method_throws = 0, method_arguments = 0;
	struct Stack *throws = NULL;
	struct Stack *arguments = NULL;
	char *argument_type, *argument_name;

	/* Atributos de una variable */
	int var_abstract = 0, var_final = 0;
	
%}

%{
	void print_tabs() {
		int i = 0;
		for(; i < tabs; i++)
			fprintf(file, "\t");
	}

	void print_stack(struct Stack *list) {
		struct node *temp;
		if(list == NULL) {
			list = (struct Stack *)malloc(sizeof(struct Stack));
			list -> first = NULL;
			list -> length = 0;
		}
		if(list -> first != NULL){
			do{
				fprintf(file, "%s", list -> first -> line);
				if(list -> first -> next != NULL)
					fprintf(file, ", ");
				list -> first = list -> first -> next;
			} while (list -> first != NULL);
			
		} else {
			printf("Empty stack (%d elements)\n", list -> length);
		}
	}

	/*
	 * Imprime la firma de una clase
	 */
	void print_class() {
		print_tabs(); 

		fprintf(file, "%s ", class_accesmod);
		free(class_accesmod);

		if(class_abstract) {
			fprintf(file, "abstract ");
			class_abstract = 0;
		}

		if(class_final) {
			fprintf(file, "final ");
			class_final = 0;
		}

		if(is_interface)
			fprintf(file, "interface ");
		else
			fprintf(file, "class ");

		fprintf(file, "%s ", class_name);
		free(class_name);

		if(class_extends) {
			fprintf(file, "extends %s ", class_super);
			free(class_super);
			class_extends = 0;
		}

		if(class_implements) {
			fprintf(file, "implements ");
			print_stack(interfaces);
			fprintf(file, " ");
			class_implements = 0;
		}

		fprintf(file, "{\n\n");
	
		load_class = 0;
		tabs++;
	}

	/*
     * imprime la firma de un metodo
	 */
	void print_method() {
		print_tabs();

		fprintf(file, "%s ", method_accesmod);
		free(method_accesmod);

		if(method_static) {
			fprintf(file, "static ");
			method_static = 0;
		}

		if(method_abstract) {
			fprintf(file, "abstract ");
		}

		if(method_final) {
			fprintf(file, "final ");
			method_final = 0;
		}

		if(method_synchronized) {
			fprintf(file, "synchronized ");
			method_synchronized = 0;
		}

		if(is_constructor == 0) {
			fprintf(file, "%s ", method_return);
			free(method_return);
		}

		fprintf(file, "%s (", method_name);
		free(method_name);

		if(method_arguments) {
			print_stack(arguments);
			method_arguments = 0;
		}

		fprintf(file, ") ");

		if(method_throws) {
			fprintf(file, "throws ");
			print_stack(throws);
			fprintf(file, " ");
			method_throws = 0;
		}

		if(is_interface) {
			fprintf(file, ";\n\n");
		} else if(method_abstract) {
			fprintf(file, ";\n\n");
			method_abstract = 0;
		} else {
			fprintf(file, "{}\n\n");
		}

		is_constructor = 0;
	}
%}

%x metodo
%x metodo_argumento
%x variable

%%

("<class>"|"<interface>") {
	if(load_class)
		print_class();
	if(yytext[1] == 'i')
		is_interface = 1;
	load_class = 1;
}

"<accesmod>".+"</accesmod>" {
	class_accesmod = malloc(yyleng);
	int i = 0, j = yyleng - 1, k = 0;
	
	while(yytext[i] != '>')
		i++;
	while(yytext[j] != '<')
		j--;

	i++;
	for(; i < j; i++, k++)
		class_accesmod[k] = yytext[i];
	class_accesmod[k] = '\0';
}

"<name>".+"</name>" {
	class_name = malloc(yyleng);
	int i = 0, j = yyleng - 1, k = 0;
	
	while(yytext[i] != '>')
		i++;
	while(yytext[j] != '<')
		j--;

	i++;
	for(; i < j; i++, k++)
		class_name[k] = yytext[i];
	class_name[k] = '\0';
}

"<abstract>".+"</abstract>" {
	class_abstract = 1;
}

"<final>".+"</final>" {
	class_final = 1;
}

"<extends>".+"</extends>" {
	class_extends = 1;
	class_super = malloc(yyleng);
	int i = 0, j = yyleng - 1, k = 0;
	
	while(yytext[i] != '>')
		i++;
	while(yytext[j] != '<')
		j--;

	i++;
	for(; i < j; i++, k++)
		class_super[k] = yytext[i];
	class_super[k] = '\0';
}

"<implements>".+"</implements>" {
	class_implements = 1;
	char *interface = malloc(yyleng);
	int i = 0, j = yyleng - 1, k = 0;

	while(yytext[i] != '>')
		i++;
	while(yytext[j] != '<')
		j--;

	i++;
	for(; i < j; i++, k++)
		interface[k] = yytext[i];
	interface[k] = '\0';

	interfaces = push(interfaces, interface);
}

("</class>"|"</interface>") {
	if(load_class)
		print_class();
	tabs--;
	is_interface = 0;
	print_tabs(); fprintf(file, "}\n\n");
}

("<method>"|"<constructor>") {
	if(load_class)
		print_class();
	if(yytext[1] == 'c')
		is_constructor = 1;
	BEGIN(metodo);
}

<metodo>{
"<accesmod>".+"</accesmod>" {
	method_accesmod = malloc(yyleng);
	int i = 0, j = yyleng - 1, k = 0;
	
	while(yytext[i] != '>')
		i++;
	while(yytext[j] != '<')
		j--;

	i++;
	for(; i < j; i++, k++)
		method_accesmod[k] = yytext[i];
	method_accesmod[k] = '\0';
}

"<static>".+"</static>" {
	method_static = 1;
}

"<abstract>".+"</abstract>" {
	method_abstract = 1;
}

"<final>".+"</final>" {
	method_final = 1;
}

"<synchronized>".+"</synchronized>" {
	method_synchronized = 1;
}

"<return>".+"</return>" {
	method_return = malloc(yyleng);
	int i = 0, j = yyleng - 1, k = 0;
	
	while(yytext[i] != '>')
		i++;
	while(yytext[j] != '<')
		j--;

	i++;
	for(; i < j; i++, k++)
		method_return[k] = yytext[i];
	method_return[k] = '\0';
}

"<name>".+"</name>" {
	method_name = malloc(yyleng);
	int i = 0, j = yyleng - 1, k = 0;
	
	while(yytext[i] != '>')
		i++;
	while(yytext[j] != '<')
		j--;

	i++;
	for(; i < j; i++, k++)
		method_name[k] = yytext[i];
	method_name[k] = '\0';
}

"<argument>" {
	method_arguments = 1;
	BEGIN(metodo_argumento);
}

"<throws>".+"</throws>" {
	method_throws = 1;
	char *exception = malloc(yyleng);
	int i = 0, j = yyleng - 1, k = 0;
	
	while(yytext[i] != '>')
		i++;
	while(yytext[j] != '<')
		j--;

	i++;
	for(; i < j; i++, k++)
		exception[k] = yytext[i];
	exception[k] = '\0';

	throws = push(throws, exception);
}

("</method>"|"</constructor>") {
	print_method();
	BEGIN(INITIAL);
}

. {}
}

<metodo_argumento>{
"<type>".+"</type>" {
	argument_type = malloc(yyleng);
	int i = 0, j = yyleng - 1, k = 0;
	
	while(yytext[i] != '>')
		i++;
	while(yytext[j] != '<')
		j--;

	i++;
	for(; i < j; i++, k++)
		argument_type[k] = yytext[i];
	argument_type[k] = '\0';
}

"<name>".+"</name>" {
	argument_name = malloc(yyleng);
	int i = 0, j = yyleng - 1, k = 0;
	
	while(yytext[i] != '>')
		i++;
	while(yytext[j] != '<')
		j--;

	i++;
	for(; i < j; i++, k++)
		argument_name[k] = yytext[i];
	argument_name[k] = '\0';
}

"</argument>" {
	int an = strlen(argument_name);
	int at = strlen(argument_type);
	int longitud = an + at + 3;
	char *arg = (char *)malloc(sizeof(char) * longitud);

	int i = 0, j = 0;
	for(; i < at; i++)
		arg[i] = argument_type[i];
	arg[i] = ' '; i++;
	for(; j < an; i++, j++)
		arg[i] = argument_name[j];
	arg[i] = '\0';

	arguments = push(arguments, arg);
	
	BEGIN(metodo);
}

}



"<var>" {
	BEGIN(variable);
}

<variable>{
"</var>" {
	BEGIN(INITIAL);
}
. {}
}

. {}

%%
main() {
	file = fopen("Clase.java","w");
	yylex();
	fclose(file);
}

int yywrap() {
	return 1;
}
