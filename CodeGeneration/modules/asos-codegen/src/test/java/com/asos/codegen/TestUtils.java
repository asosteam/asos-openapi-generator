package com.asos.codegen;

import io.swagger.parser.OpenAPIParser;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.Paths;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.media.Schema;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.parser.core.models.ParseOptions;
import com.asos.codegen.model.ModelMap;
import com.asos.codegen.model.ModelsMap;
import com.asos.codegen.utils.ModelUtils;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;

import static org.testng.Assert.*;

public class TestUtils {

    /**
     * Helper method for parsing specs as a generator would be presented at runtime (inline models resolved, flattened).
     *
     * @param specFilePath The path to the specification file
     * @return A processed OpenAPI document
     */
    public static OpenAPI parseFlattenSpec(String specFilePath) {
        OpenAPI openAPI = parseSpec(specFilePath);
        InlineModelResolver inlineModelResolver = new InlineModelResolver();
        inlineModelResolver.flatten(openAPI);
        return openAPI;
    }

    /**
     * Helper method for parsing specs into an intermediary OpenAPI structure for pre-processing.
     *
     * Use this method only for tests targeting processing helpers such as {@link com.asos.codegen.utils.ModelUtils}
     * or {@link InlineModelResolver}. Using this for testing generators will mean you're not testing the OpenAPI document
     * in a state the generator will be presented at runtime.
     *
     * @param specFilePath The path to the specification file
     * @return A "raw" OpenAPI document
     */
    public static OpenAPI parseSpec(String specFilePath) {
        OpenAPI openAPI = new OpenAPIParser().readLocation(specFilePath, null, new ParseOptions()).getOpenAPI();
        // Invoke helper function to get the original swagger version.
        // See https://github.com/swagger-api/swagger-parser/pull/1374
        // Also see https://github.com/swagger-api/swagger-parser/issues/1369.
        ModelUtils.getOpenApiVersion(openAPI, specFilePath, null);
        return openAPI;
    }

    public static OpenAPI parseContent(String jsonOrYaml) {
        OpenAPI openAPI = new OpenAPIParser().readContents(jsonOrYaml, null, null).getOpenAPI();
        // Invoke helper function to get the original swagger version.
        ModelUtils.getOpenApiVersion(openAPI, jsonOrYaml, null);
        return openAPI;
    }

    public static OpenAPI createOpenAPI() {
        OpenAPI openAPI = new OpenAPI();
        openAPI.setComponents(new Components());
        openAPI.setPaths(new Paths());

        final Info info = new Info();
        info.setDescription("API under test");
        info.setVersion("1.0.7");
        info.setTitle("My title");
        openAPI.setInfo(info);

        final Server server = new Server();
        server.setUrl("https://localhost:9999/root");
        openAPI.setServers(Collections.singletonList(server));
        return openAPI;
    }

    public static OpenAPI createOpenAPIWithOneSchema(String name, Schema<?> schema) {
        OpenAPI openAPI = createOpenAPI();
        openAPI.setComponents(new Components());
        openAPI.getComponents().addSchemas(name, schema);
        return openAPI;
    }

    public static void ensureContainsFile(List<File> generatedFiles, File root, String filename) {
        Path path = root.toPath().resolve(filename);
        assertTrue(generatedFiles.contains(path.toFile()), "File '" + path.toAbsolutePath() + "' was not found in the list of generated files");
    }

    public static void ensureDoesNotContainFile(List<File> generatedFiles, File root, String filename) {
        Path path = root.toPath().resolve(filename);
        assertFalse(generatedFiles.contains(path.toFile()), "File '" + path.toAbsolutePath() + "' was found in the list of generated files");
    }

    public static void assertFileContains(Path path, String... lines) {
        try {
            String generatedFile = Files.readString(path);
            String file = linearize(generatedFile);
            assertNotNull(file);
            for (String line : lines)
                assertTrue(file.contains(linearize(line)), "File does not contain line [" + line + "]");
        } catch (IOException e) {
            fail("Unable to evaluate file " + path);
        }
    }

    public static String linearize(String target) {
        return target.replaceAll("\r?\n", "").replaceAll("\\s+", "\\s");
    }

    public static void assertFileNotContains(Path path, String... lines) {
        String generatedFile = null;
        try {
            generatedFile = Files.readString(path);
        } catch (IOException e) {
            fail("Unable to evaluate file " + path);
        }
        String file = linearize(generatedFile);
        assertNotNull(file);
        for (String line : lines)
            assertFalse(file.contains(linearize(line)));
    }

    public static void assertFileNotExists(Path path) {
        try {
            Files.readString(path);
            fail("File exists when it should not: " + path);
        } catch (IOException e) {
            // File exists, pass.
            assertTrue(true);
        }
    }

    public static void assertFileExists(Path path) {
        try {
            Files.readString(path);
            // File exists, pass.
            assertTrue(true);
        } catch (IOException e) {
            fail("File does not exist when it should: " + path);
        }
    }

    public static ModelsMap createCodegenModelWrapper(CodegenModel cm) {
        ModelsMap objs = new ModelsMap();
        List<ModelMap> modelMaps = new ArrayList<>();
        ModelMap modelMap = new ModelMap();
        modelMap.setModel(cm);
        modelMaps.add(modelMap);
        objs.setModels(modelMaps);
        return objs;
    }

    public static Path newTempFolder() {
        final Path tempDir;
        try {
            tempDir = Files.createTempDirectory("test");
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        tempDir.toFile().deleteOnExit();

        return tempDir;
    }
}
