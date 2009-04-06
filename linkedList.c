#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Linked list node
struct node {
	char *line;
	struct node *next;
};

// Linked List structure
struct LinkedList {
	struct node *first;
	int length;
};

// Inserts a string at the end of the list
struct LinkedList *insert(struct LinkedList *list, char *text) {
	if(list == NULL) {
		printf("Initializing list on method insert\n");
		list = (struct LinkedList *)malloc(sizeof(struct LinkedList));
		list -> first = NULL;
		list -> length = 0;
	}
	
	struct node *temp;
	char *ttext = NULL;
	ttext = (char *)malloc(sizeof(char)*strlen(text)+ 1);
	strcpy(ttext,text);
	
	if(list -> first == NULL){
		(list -> first) = (struct node *)malloc(sizeof(struct node));
		// Just in case of error
		if(list -> first == NULL) {
			printf("== Error assingning memory ==\n");
			exit(0);
		}
		(list -> first) -> line = ttext;
		(list -> first) -> next = NULL;
		(list -> length)++;
	} else {
		temp = list -> first;
		while (temp -> next != NULL) {
			temp = temp -> next;
		}
		temp -> next = (struct node *)malloc(sizeof(struct node));
		// Just in case of error
		if(temp -> next == NULL){
			printf("== Error assingning memory ==\n");
			exit(0);
		}
		temp = temp -> next;
		temp -> line = ttext;
		temp -> next = NULL;
		(list -> length)++;
	}
	return list;
}

void printlist(struct LinkedList *list){
	struct node *temp;
	if(list == NULL) {
		printf("Initializing list on method print\n");
		list = (struct LinkedList *)malloc(sizeof(struct LinkedList));
		list -> first = NULL;
		list -> length = 0;
	}
	temp = list -> first;
	int j = 0;
	if(list -> first != NULL){
		printf("The text lines in the list are:\n");
		do{
			printf("[%d] - %s", j, temp -> line);
			if(temp -> next != NULL)
				printf("\n");
			temp = temp -> next;
			j++;
		} while (temp != NULL);
		printf("\n");
	} else {
		printf("The list is empty (%d elements)\n", list -> length);
	}
}

struct LinkedList *insertAt(int index, char *text, struct LinkedList *list){
	if(list == NULL) {
		printf("Initializing list on method insertAt\n");
		list = (struct LinkedList *)malloc(sizeof(struct LinkedList));
		list -> first = NULL;
		list -> length = 0;
	}
	struct node *temp;
	struct node *temp2;
	char *ttext = NULL;
	
	int i = 0;
	if(index < (list -> length) && index >= 0) {
	
		ttext = (char *)malloc(sizeof(char)*strlen(text)+ 1);
		strcpy(ttext,text);
		
		printf("Searching index %d...\n", index);
		
		temp = list -> first;
		temp2 = (struct node *)malloc(sizeof(struct node));
		temp2 -> line = ttext;
		
		if(index == 0){
			temp2 -> next = temp;
			list -> first = temp2;
		} else {
			while(i < index - 1){
				temp = temp -> next;
				i++;
			}
			// Just in case of error
			if(temp2 == NULL) {
				printf("== Error assingning memory ==\n");
				exit(0);
			}
			temp2 -> next = temp -> next;
			temp -> next = temp2;
			(list -> length)++;
		}
	} else
		printf("Tried to insert outside the list, no changes made\n");
	return list;
}

char *elementAt(int index, struct LinkedList *list){
	if(list == NULL) {
		printf("Initializing list on method elementAt\n");
		list = (struct LinkedList *)malloc(sizeof(struct LinkedList));
		list -> first = NULL;
		list -> length = 0;
	}
	struct node *temp;
	int i = 0;
	if(index < (list -> length) && index >= 0) {
		printf("Searching index %d...\n", index);
		temp = list -> first;
		while(i < index){
			temp = temp -> next;
			i++;
		}
		return temp -> line;
	} else {
		printf("That node doesn't exist\n");
		return NULL;
	}
}

// Erase jumplines on a string
void ejlines(char original[]){
	int j;
	for(j = 0; j < strlen(original); j++){
		if(original[j] == '\n'){
			original[j] = ' ';
		}
	}
}

int main() {
	printf("*** String-linked-list by RoD ***\n\n");
	printf("Demo of a string's list:\n");
	struct LinkedList *demo = NULL;
	demo = insert(demo, "Linea uno");
	demo = insert(demo, "Linea dos");
	demo = insert(demo, "Linea tres");
	printf("La segunda linea dice: '%s'\n", elementAt(1,demo));
	printlist(demo);
	
	
	// File name length of 500
	char name_of_file[500];
	printf("\nNow you can write the name a the file to open:\n");
	scanf("%s", name_of_file);
	FILE *f;
	f = fopen(name_of_file, "r");
	if(f == NULL) {
		printf("Can't open the file ('%s')\nExiting now...\n", name_of_file);
		return 0;
	}
	printf("Opening file '%s' [ OK ]\n", name_of_file);
	char buffer[151];
	struct LinkedList *start = NULL;
	while(!feof(f)){
		if(fgets(buffer,150,f)){
			ejlines(buffer);
			start = insert(start, buffer);
		}
	}
	printf("End of file\n");
	fclose(f);
	
	start = insertAt(193,"Rodrigo es el mejor", start);
	start = insertAt(0, "Me falto esto al iniciar", start);
	start = insertAt(1, "Y esto después de lo que me faltó", start);
	
	printlist(start);
	
	
	return 0;
}
