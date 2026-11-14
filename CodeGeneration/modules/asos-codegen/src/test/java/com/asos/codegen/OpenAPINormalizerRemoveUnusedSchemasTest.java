package com.asos.codegen;

import io.swagger.v3.oas.models.OpenAPI;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class OpenAPINormalizerRemoveUnusedSchemasTest {

    private static final String SPEC = "src/test/resources/2_0/swift/petstore-with-fake-endpoints-models-for-testing.yaml";

    @Test(description = "FILTER + REMOVE_UNUSED_SCHEMAS keeps only the operation and the schemas it reaches")
    public void keepsOnlySchemasOfFilteredOperation() {
        OpenAPI openAPI = TestUtils.parseSpec(SPEC);
        Map<String, String> rules = new HashMap<>();
        rules.put("FILTER", "operationId:getPetById");
        rules.put("REMOVE_UNUSED_SCHEMAS", "true");

        new OpenAPINormalizer(openAPI, rules).normalize();

        Set<String> schemas = openAPI.getComponents().getSchemas().keySet();
        Assert.assertEquals(schemas, Set.of("Pet", "Category", "Tag"));
        Assert.assertEquals(openAPI.getPaths().keySet(), Set.of("/pet/{petId}"));
        Assert.assertNotNull(openAPI.getPaths().get("/pet/{petId}").getGet());
        Assert.assertNull(openAPI.getPaths().get("/pet/{petId}").getPost());
        Assert.assertNull(openAPI.getPaths().get("/pet/{petId}").getDelete());
    }

    @Test(description = "REMOVE_UNUSED_SCHEMAS alone drops schemas no operation references")
    public void dropsUnreferencedSchemasWithoutFilter() {
        OpenAPI openAPI = TestUtils.parseSpec(SPEC);
        int operationCount = openAPI.getPaths().values().stream().mapToInt(p -> p.readOperations().size()).sum();
        Map<String, String> rules = new HashMap<>();
        rules.put("REMOVE_UNUSED_SCHEMAS", "true");

        new OpenAPINormalizer(openAPI, rules).normalize();

        Set<String> schemas = openAPI.getComponents().getSchemas().keySet();
        Assert.assertTrue(schemas.contains("Pet"));
        Assert.assertTrue(schemas.contains("Order"));
        Assert.assertFalse(schemas.contains("Dog"), "Dog is only referenced by other unused schemas");
        Assert.assertEquals(openAPI.getPaths().values().stream().mapToInt(p -> p.readOperations().size()).sum(), operationCount);
    }

    @Test(description = "Without the rule all schemas are kept")
    public void keepsEverythingWhenDisabled() {
        OpenAPI openAPI = TestUtils.parseSpec(SPEC);
        int schemaCount = openAPI.getComponents().getSchemas().size();
        Map<String, String> rules = new HashMap<>();
        rules.put("FILTER", "operationId:getPetById");

        new OpenAPINormalizer(openAPI, rules).normalize();

        Assert.assertEquals(openAPI.getComponents().getSchemas().size(), schemaCount);
    }
}
