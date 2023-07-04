package solv.db;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import solv.db.solvb.SolvencyDatabase;


@Configuration
public class CartDatabaseConfig {

    @Bean
    public SolvencyDatabase solvencyDatabase() {
        return new SolvencyDatabase();
    }

}