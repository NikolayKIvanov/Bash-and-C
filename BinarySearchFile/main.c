#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <err.h>

int main (int argc, char* argv[])
{
	if(argc!=3)
	{ 	
		errx(1, "err");
	}

	const int fd = open(argv[1], O_RDONLY);
	if(fd < 0)
	{
		err(2, "open %s", argv[2]);	
	}

	int up = 0;
	int down = lseek(fd, 0, SEEK_END);
	if(down < 0)
	{
		close(fd);
		err(3, "lseek %s", argv[2]);
	}

	int cmp = 0;
	int curr = 0;
	char b = ' ';

	while(1)
	{
		curr = lseek(fd, (up + down) / 2, SEEK_SET);
		while((read(fd, &b, 1)) && b != '\0') {}

		int temp = lseek(fd, 0, SEEK_CUR);
		int index = 0;
		while((read(fd, &b, 1)) && b != '\n')
		{
			index++;
		}

		char *word = malloc(index+1);
		lseek(fd, temp, SEEK_SET);
		index = 0;
		while((read(fd, &b, 1)) && b != '\n')
		{
			word[index++] = b;
		}

		b=' ';
		word[index] = '\0';
		cmp = strcmp(argv[2], word);
		free(word);
		if(cmp == 0)
		{	
			while((read(fd, &b, 1)) && b!='\0')
			{
				write(1, &b, 1);
			}
	
			break;
		}

		if(up == curr)
		{
			write(1, "No such word in the dictionary!\n", 32);
			break;
		}
	
		if(cmp < 0)
		{
			down = curr;
		} 
		else
		{
			up = curr;
		}
	}

	close(fd);

	return 0;
}
