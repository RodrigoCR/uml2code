#include <stdio.h>
#include <stdlib.h>

struct node {
	char *line;
	struct node *link;
};

struct node *insert(struct node *p, char *text) {
	struct node *temp;
	char *tempstr;
	if(p == NULL){
		p = (struct node *)malloc(sizeof(struct node));
		// Just in case of error
		if(p == NULL) {
			printf("== Error assingning memory ==\n");
			exit(0);
		}
		tempstr = text;
		p -> line = tempstr;
		p -> link = NULL;
	} else {
		temp = p;
		while (temp -> link != NULL) {
			temp = temp -> link;
		}
		temp -> link = (struct node *)malloc(sizeof(struct node));
		// Just in case of error
		if(temp -> link == NULL){
			printf("Error\n");
			exit(0);
		}
		temp = temp -> link;
		tempstr = text;
		temp -> line = tempstr;
		temp -> link = NULL;
	}
	return(p);
}

void printlist(struct node *p){
	struct node *temp;
	temp = p;
	int j = 1;
	if(p!= NULL){
		printf("The text lines in the list are:\n");
		do{
			printf("%d.- %s", j, temp -> line);
			if(temp -> link != NULL)
				printf("\n");
			temp = temp -> link;
			j++;
		} while (temp != NULL);
		printf("\n");
	} else {
		printf("The list is empty\n");
	}
}

int main() {
	printf("*** File 2 string-list by RoD ***\n*\n");
	printf("Demo of a string's list:\n");
	struct node *demo = NULL;
	demo = insert(demo, "Linea uno");
	demo = insert(demo, "Linea dos");
	demo = insert(demo, "Linea tres");
	printlist(demo);
	
	// File name length of 500
	char name_of_file[500];
	printf("*\nNow you can write the name a the file to open:\n");
	scanf("%s", name_of_file);
	FILE *f;
	f = fopen(name_of_file, "r");
	if(f == NULL) {
		printf("Can't open the file ('%s')\nExiting now...\n", name_of_file);
		return 0;
	}
	printf("Opening file '%s' [ OK ]\n", name_of_file);
	char *buffer;
	struct node *start = NULL;
	while(!feof(f)){
		if(fgets(buffer,150,f)){
			start = insert(start, buffer);
			printf("Inserted: %s\n", buffer);
		}
	}
	printf("End of file\n");
	fclose(f);

	printlist(start);
	
	return 0;
}
