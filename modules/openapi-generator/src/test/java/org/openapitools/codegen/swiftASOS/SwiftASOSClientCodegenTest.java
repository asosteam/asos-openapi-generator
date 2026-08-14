/*
 * Copyright 2018 OpenAPI-Generator Contributors (https://openapi-generator.tech)
 * Copyright 2018 SmartBear Software
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.openapitools.codegen.swiftASOS;

import org.openapitools.codegen.CodegenProperty;
import org.openapitools.codegen.DefaultCodegen;
import org.openapitools.codegen.languages.SwiftASOSClientCodegen;
import org.testng.Assert;
import org.testng.annotations.Test;

public class SwiftASOSClientCodegenTest {

    // ── Model naming ─────────────────────────────────────────────────────────────

    public static class ModelNamingTest {
        SwiftASOSClientCodegen codegen = new SwiftASOSClientCodegen();

        @Test(description = "Asos→ASOS replacement is applied to model names (mixed and lowercase prefix)")
        public void replacementTest() {
            DefaultCodegen dg = new SwiftASOSClientCodegen();

            dg.setModelNamePrefix("Asos");
            Assert.assertEquals(dg.toModelName("Error"), "ASOSError");

            dg.setModelNamePrefix("asos");
            Assert.assertEquals(dg.toModelName("Error"), "ASOSError");
        }

        @Test(description = "Asos→ASOS replacement is applied to model filenames via toModelName")
        public void toModelFilenameReplacementTest() {
            Assert.assertEquals(codegen.toModelFilename("AsosProduct"), "ASOSProduct");
            Assert.assertEquals(codegen.toModelFilename("MyAsosResponse"), "MyASOSResponse");
        }

        @Test(description = "Id→ID and Url→URL inherited replacements are applied to model filenames")
        public void toModelFilenameInheritedReplacementsTest() {
            Assert.assertEquals(codegen.toModelFilename("UserId"), "UserID");
            Assert.assertEquals(codegen.toModelFilename("ProfileUrl"), "ProfileURL");
        }
    }

    // ── Variable and parameter naming ────────────────────────────────────────────

    public static class VariableAndParameterNamingTest {
        SwiftASOSClientCodegen codegen = new SwiftASOSClientCodegen();

        @Test(description = "Asos→ASOS replacement is applied to variable and parameter names (called via DefaultCodegen reference)")
        public void replacementTest() {
            DefaultCodegen dg = new SwiftASOSClientCodegen();

            Assert.assertEquals(dg.toVarName("asosId"), "ASOSID");
            Assert.assertEquals(dg.toParamName("asosId"), "ASOSID");
        }

        @Test(description = "Asos→ASOS replacement is applied to variable names")
        public void toVarNameReplacementTest() {
            Assert.assertEquals(codegen.toVarName("asosId"), "ASOSID");
            Assert.assertEquals(codegen.toVarName("asos_id"), "ASOSID");
        }

        @Test(description = "Asos→ASOS replacement is applied to parameter names")
        public void toParamNameReplacementTest() {
            Assert.assertEquals(codegen.toParamName("asosId"), "ASOSID");
            Assert.assertEquals(codegen.toParamName("asos_id"), "ASOSID");
        }

        @Test(description = "Id→ID and Url→URL replacements inherited from Swift5 still apply")
        public void inheritedReplacementsTest() {
            Assert.assertEquals(codegen.toVarName("user_id"), "userID");
            Assert.assertEquals(codegen.toVarName("profile_url"), "profileURL");
            Assert.assertEquals(codegen.toOperationId("getUserId"), "getUserID");
        }
    }

    // ── Operation naming ─────────────────────────────────────────────────────────

    public static class OperationNamingTest {
        SwiftASOSClientCodegen codegen = new SwiftASOSClientCodegen();

        @Test(description = "Asos→ASOS replacement is applied to operation IDs")
        public void toOperationIdReplacementTest() {
            Assert.assertEquals(codegen.toOperationId("getAsosProfile"), "getASOSProfile");
        }
    }

    // ── Enum naming ──────────────────────────────────────────────────────────────

    public static class EnumNamingTest {
        SwiftASOSClientCodegen codegen = new SwiftASOSClientCodegen();

        @Test(description = "Asos→ASOS replacement is applied to enum type names via toModelName")
        public void toEnumNameReplacementTest() {
            CodegenProperty prop = new CodegenProperty();
            prop.name = "asosStatus";
            prop.datatypeWithEnum = "SomeOtherType";
            Assert.assertEquals(codegen.toEnumName(prop), "ASOSStatus");
        }

        @Test(description = "toEnumVarName does not apply Asos→ASOS replacement (enum values come verbatim from the spec)")
        public void toEnumVarNameNoAsosReplacementTest() {
            Assert.assertEquals(codegen.toEnumVarName("asos_active", "String"), "asosActive");
            Assert.assertEquals(codegen.toEnumVarName("asos_inactive", "String"), "asosInactive");
        }
    }

    // ── API naming ───────────────────────────────────────────────────────────────

    public static class ApiNamingTest {
        SwiftASOSClientCodegen codegen = new SwiftASOSClientCodegen();

        @Test(description = "toApiName appends API suffix and camelizes; empty name returns DefaultAPI")
        public void toApiNameTest() {
            Assert.assertEquals(codegen.toApiName("product"), "ProductAPI");
            Assert.assertEquals(codegen.toApiName(""), "DefaultAPI");
        }
    }

    // ── Reserved word escaping ───────────────────────────────────────────────────

    public static class ReservedWordEscapingTest {

        @Test(description = "escapeReservedWord uses underscore prefix by default")
        public void escapeReservedWordDefaultTest() {
            SwiftASOSClientCodegen codegen = new SwiftASOSClientCodegen();
            Assert.assertEquals(codegen.escapeReservedWord("class"), "_class");
            Assert.assertEquals(codegen.escapeReservedWord("operator"), "_operator");
        }

        @Test(description = "escapeReservedWord uses backtick when useBacktickEscapes is enabled")
        public void escapeReservedWordBacktickTest() {
            SwiftASOSClientCodegen codegen = new SwiftASOSClientCodegen();
            codegen.setUseBacktickEscapes(true);
            Assert.assertEquals(codegen.escapeReservedWord("class"), "`class`");
            Assert.assertEquals(codegen.escapeReservedWord("operator"), "`operator`");
        }

        @Test(description = "objcCompatible overrides backtick mode and falls back to underscore")
        public void escapeReservedWordObjcCompatibleTest() {
            SwiftASOSClientCodegen codegen = new SwiftASOSClientCodegen();
            codegen.setUseBacktickEscapes(true);
            codegen.setObjcCompatible(true);
            Assert.assertEquals(codegen.escapeReservedWord("class"), "_class");
        }
    }
}
