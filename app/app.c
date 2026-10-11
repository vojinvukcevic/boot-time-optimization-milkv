#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <fcntl.h>

#define MYPORT 5005


int read_sensor(double *temperature){
	int fd_temperature; 
	fd_temperature = open("/sys/bus/iio/devices/iio:device0/in_temp_input", O_RDONLY);
	if(fd_temperature < 0){
		perror("open temperature");
		return -1;
		}

	char buf_temp[64];
	int t_read;
	
	t_read = read(fd_temperature, buf_temp, sizeof buf_temp - 1);
	
	close(fd_temperature);
	
	if(t_read <= 0) {
		perror("read");
		return -1;
	}
	
	buf_temp[t_read] = '\0';

	int temp_value = atoi(buf_temp);

	*temperature = temp_value / 1000.0;

	return 0;
}

int main(void){
	int sockfd;
	struct sockaddr_in dest_addr;
	double temperature;
	char msg[64];

	sockfd = socket(AF_INET, SOCK_DGRAM, 0 );  
	if(sockfd < 0) {
		perror("socket");
		exit(1);
	}
	memset(&dest_addr, 0, sizeof dest_addr);
	dest_addr.sin_family = AF_INET;
	dest_addr.sin_port = htons(MYPORT);
	if (inet_pton(AF_INET, "192.168.10.1", &dest_addr.sin_addr) != 1) {
    		perror("inet_pton");
    		return 1;
	}
	
	if(read_sensor(&temperature) < 0){
		return 1;
	}

	snprintf(msg, sizeof msg, "temp=%.3f", temperature);

	if (sendto(sockfd, msg, strlen(msg), 0, (struct sockaddr *)&dest_addr,  sizeof(dest_addr)) < 0){
		perror("sendto");
		exit(1);
	}
	close(sockfd);
	write(1, "Temperature sent\n",17);
	return 0;
	
}

