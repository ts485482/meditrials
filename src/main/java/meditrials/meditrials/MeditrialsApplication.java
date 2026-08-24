package meditrials.meditrials;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class MeditrialsApplication {

	public static void main(String[] args) {
		SpringApplication.run(MeditrialsApplication.class, args);
	}

}
