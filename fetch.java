///usr/bin/env jbang "$0" "$@" ; exit $?
//JAVA 11+
//JAVAC_OPTIONS -Xlint:unchecked
//DEPS info.picocli:picocli:4.5.0
//DEPS org.jsoup:jsoup:1.14.2
//DEPS com.microsoft.playwright:playwright:1.28.0

import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.Playwright;
import com.microsoft.playwright.options.Cookie;
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
import java.util.regex.Pattern;
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
        Config config;
        System.out.println("Trying to capture a set of session cookies to use...");
        try (Playwright playwright = Playwright.create()) {
            try (Browser b = playwright.firefox().launch()) {
                Browser.NewContextOptions options = new Browser.NewContextOptions();
                String userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:53.0) Gecko/20100101 Firefox/53.0";
                options.setUserAgent(userAgent);
                BrowserContext ctx = b.newContext(options);
                Page page = ctx.newPage();
                page.route("**", route -> {
                    System.out.printf("  FETCH %s%n", route.request().url());
                    route.resume();
                });
                page.navigate("https://data.gov.il/dataset/covid-19");
                System.out.println("Waiting for Javascript to request a session cookie...");
                page.waitForResponse(Pattern.compile("/[A-Za-z0-9]{8}[A-Za-z0-9]+/[^/]+"), () -> {
                });
                System.out.println("Waiting for redirect back to original request page...");
                page.waitForResponse(Pattern.compile("/dataset/covid-19"), () -> {
                });
                System.out.println("Extracting cookies...");
                String rbzid = null;
                String rbzsessionid = null;
                for (Cookie c : ctx.cookies()) {
                    switch (c.name) {
                        case "rbzid":
                            rbzid = c.value;
                            break;
                        case "rbzsessionid":
                            rbzsessionid = c.value;
                            break;
                        default:
                            break;
                    }
                }
                if (rbzid == null || rbzsessionid == null) {
                    throw new RuntimeException("Could not capture session cookies");
                }
                config = new Config(userAgent, rbzid, rbzsessionid);
            }
        }
        System.out.println("Fetching index page...");
        Document doc = fetchIndex(config);
        System.out.println("Looking for current download links...");
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
        System.out.println("Done.");
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

    public static class Config {
        private final String agent;
        private final String rbzid;
        private final String rbzsessionid;

        public Config(String agent, String rbzid, String rbzsessionid) {
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
