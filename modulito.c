#include <dirent.h> 
#include <unistd.h> 
#include <stdio.h> 
#include <string.h>
#include <sys/stat.h> // struct stat
int nfiles=0;
 FILE *filelist;
void search(char* path,char *ext)
{
	int lon_ext=strlen(ext);
	int lon_file=strlen(path);
	int founded=0;
	DIR* dp;
	dp = opendir(path);

	if (dp == NULL)
	{//Can't open the current dir
		return;
	}

	struct dirent* dirp;
	while( (dirp = readdir(dp)) != NULL )
        {
               if (strcmp(dirp->d_name,".") == 0 || strcmp(dirp->d_name,"..") == 0)//We avoid a loop
                        continue;
		if(dirp->d_name){
		  char *resp;char *f;
		  resp=strstr(dirp->d_name,ext);
		  if(resp!=NULL&&*(resp+lon_ext)!='~'){
		    printf("\t%s%s\n", path,dirp->d_name);
		    founded=1;
		  }
 }
                struct stat buf;
                stat(dirp->d_name, &buf);
                if (S_ISDIR(buf.st_mode))
                {
                        char tmpPath[256]="";
                        strcat(tmpPath,path);
			if(tmpPath[lon_file-1]!='/')
			  strcat(tmpPath,"/");
                        strcat(tmpPath,dirp->d_name);
                        strcat(tmpPath,"/");
 			printf("Buscando en Directorio:%s%s\n", path,dirp->d_name);
                        search(tmpPath,ext);
                }
		if(founded==1){
 		    fprintf(filelist,"%s",path);
 		    fprintf(filelist,"%s",dirp->d_name); //print in a file
 		    fprintf(filelist,"\n");
		    founded=0;
		}
        }
	
}

int main(int argc, char* argv[])
{
 	filelist=fopen("files.txt","w");
 	if(filelist==NULL) return 1;
	search(".",".c");
 	fclose(filelist);
}
