///usr/bin/env jbang "$0" "$@" ; exit $?
//JAVA 11+
//JAVAC_OPTIONS -Xlint:unchecked
//DEPS info.picocli:picocli:4.5.0
//DEPS com.fasterxml.jackson.core:jackson-databind:2.12.4
//DEPS  org.jsoup:jsoup:1.14.2

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.net.URL;
import java.net.URLConnection;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;


@Command(
        description = "Fetch the latest data",
        mixinStandardHelpOptions = true,
        version = "latest"
)
public class fetch implements Runnable {

    @Option(names = {"-c", "--config-file"},
            description = "The JSON configuration file that containst the request headers to authenticate with",
            defaultValue = ".fetch.json")
    String configFile;

    public static void main(String... args) {
        CommandLine cmd = new CommandLine(new fetch());
        int exitCode = cmd.execute(args);
        System.exit(exitCode);
    }

    @Override
    public void run() {
        Config config = loadConfig();
        System.out.printf("User-Agent: %s%n", config.getAgent());
        Document doc = fetchIndex(config);
        doc.select("a")
                .stream()
                .map(e -> e.attr("href"))
                .filter((href -> href.startsWith("/dataset/covid-19/resource/")))
                .filter(href -> href.contains("/download/"))
                .filter(href -> href.endsWith(".csv") || href.endsWith(".xlsx"))
                .filter(href -> !href.contains("corona_city_table")) // too big
                .filter(href -> !href.contains("corona_lab_tests")) // too big
                .filter(href -> !href.contains("corona_recovered")) // too big
                .filter(href -> !href.contains("corona_tested_individuals")) // too big
                .filter(href -> !href.contains("geographic-sum-per-day")) // too big
                .filter(href -> !href.contains("vaccinated_city_table")) // too big
                .map(href -> "https://data.gov.il" + href)
                .forEach(href -> {
                    int lastSlash = href.lastIndexOf('/');
                    if (lastSlash == -1) {
                        return;
                    }
                    String fileName = href.substring(lastSlash + 1);
                    if (href.contains("09e66a69-ad5b-4c46-a5d9-1d1479b1f338") && fileName.startsWith("-_")) {
                        // A special case file that is missing a sensible name
                        fileName = "corona_tested_summary" + fileName.substring(1);
                    }
                    Path outputPath = Paths.get("data", fileName);
                    if (Files.exists(outputPath)) {
                        System.out.printf("Skipping %s as previously fetched%n", fileName);
                        return;
                    }
                    try {
                        URL url = new URL(href);
                        URLConnection connection = url.openConnection();
                        connection.setRequestProperty("User-Agent", config.getAgent());
                        connection.setRequestProperty("Cookie",
                                String.format("rbzid=%s; rbzsessionid=%s", config.getRbzid(),
                                        config.getRbzsessionid()));
                        try (InputStream is = connection.getInputStream();
                             BufferedInputStream bis = new BufferedInputStream(is)) {
                            Files.copy(bis, outputPath, StandardCopyOption.REPLACE_EXISTING);
                        }
                        System.out.printf("Downloaded new data file %s%n", fileName);
                    } catch (IOException e) {
                        throw new UncheckedIOException(e);
                    }
                });
    }

    private Document fetchIndex(Config config) {
        try {
            return Jsoup.connect("https://data.gov.il/dataset/covid-19")
                    .header("User-Agent", config.getAgent())
                    .cookie("rbzid", config.getRbzid())
                    .cookie("rbzsessionid", config.getRbzsessionid())
                    .get();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    private Config loadConfig() {
        try {
            Path configPath = Paths.get(configFile);
            if (!Files.exists(configPath)) {
                String fetchJson = System.getenv("FETCH_JSON");
                if (fetchJson != null && fetchJson.trim().length() > 0) {
                    return new ObjectMapper().reader().readValue(fetchJson, Config.class);
                }
                throw new RuntimeException("No authentication configuration available. Neither " + configFile
                        + " exists nor FETCH_JSON environment set");
            } else {
                return new ObjectMapper().reader().readValue(Files.readAllBytes(Paths.get(configFile)), Config.class);
            }
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    public static class Config {
        private final String agent;
        private final String rbzid;
        private final String rbzsessionid;

        @JsonCreator
        public Config(@JsonProperty(value = "agent", required = true) String agent,
                      @JsonProperty(value = "rbzid", required = true) String rbzid,
                      @JsonProperty(value = "rbzsessionid", required = true) String rbzsessionid) {
            this.agent = agent;
            this.rbzid = rbzid;
            this.rbzsessionid = rbzsessionid;
        }

        public String getAgent() {
            return agent;
        }

        public String getRbzid() {
            return rbzid;
        }

        public String getRbzsessionid() {
            return rbzsessionid;
        }
    }
}
