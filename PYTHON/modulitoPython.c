#include <dirent.h> 
#include <unistd.h> 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h> // struct stat

int nfiles = 0;
FILE *filelist;

void search(char* path, char *ext) {
	int lon_ext = strlen(ext);
	int lon_file = strlen(path);
	int founded = 0;
	DIR* dp;
	dp = opendir(path);

	if (dp == NULL) { //Can't open the current dir
		return;
	}

	struct dirent* dirp;
	while( (dirp = readdir(dp)) != NULL ) {
		if (strcmp(dirp->d_name,".") == 0 || strcmp(dirp->d_name,"..") == 0) //We avoid a loop
			continue;
		if(dirp->d_name) {
			char *resp;
			char *f;
			resp = strstr(dirp->d_name,ext);
			if(resp != NULL && *(resp+lon_ext) != '~') {
				nfiles++;
		    	founded = 1;
		    }
		}
		struct stat buf;
		stat(dirp->d_name, &buf);
		if(S_ISDIR(buf.st_mode)) {
			char tmpPath[256] = "";
			strcat(tmpPath,path);
			if(tmpPath[lon_file-1]!='/')
				strcat(tmpPath,"/");
			strcat(tmpPath,dirp->d_name);
			strcat(tmpPath,"/");
			printf("Searching on dir: %s%s\n", path,dirp->d_name);
			search(tmpPath,ext);
		}
		if(founded == 1){
			fprintf(filelist,"%s",path);
			fprintf(filelist,"%s",dirp->d_name); //print in a file
			fprintf(filelist,"\n");
			founded = 0;
		}
	}
}

char *getFileName(char *dir) {
	int i, fsize = 0, j = 0;
	for(i = strlen(dir); i >= 0; i--) {
		if(dir[i] == '/'){
			j = i + 1;
			break; break;
		}
		fsize++;
	}
	char *word = (char *) malloc(sizeof(char)*fsize);
	for(i = j; i < strlen(dir); i++){
		word[i - j] = dir[i];
	}
	word[fsize] = '\0';
	return word;
}

int main(int argc, char* argv[]) {
	char project_name[200];
	printf("Write the name of the project\n");
	scanf("%s", project_name);
	strcat(project_name, ".u2c");
	system("[ -d u2c ] || mkdir u2c");
	filelist = fopen(project_name,"w");
	if(filelist == NULL){
		printf("Can't create the project file\n");
		return 0;
	}
	search(".",".py");
	fclose(filelist);
	printf("Total files: [%i]\n", nfiles);
	
	
	return 0;
}
