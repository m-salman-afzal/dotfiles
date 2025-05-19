import js from "@eslint/js";
import eslintNext from "@next/eslint-plugin-next";
import pluginPrettier from "eslint-plugin-prettier/recommended";
import eslintReact from "eslint-plugin-react";
import reactHooks from "eslint-plugin-react-hooks";
import reactRefresh from "eslint-plugin-react-refresh";
import globals from "globals";
import tseslint from "typescript-eslint";

export default tseslint.config(
    {ignores: ["dist"]},
    {
        extends: [js.configs.recommended, ...tseslint.configs.recommended, pluginPrettier],
        files: ["**/*.{ts,tsx}"],
        ignores: ["**/*.woff", ".turbo", "styled-system", "node_modules", ".prettierignore", "apps/web/public"],
        languageOptions: {
            ecmaVersion: "latest",
            globals: globals.browser
        },
        plugins: {
            "react-hooks": reactHooks,
            "react-refresh": reactRefresh,
            react: eslintReact,
            "@next/next": eslintNext
        },
        rules: {
            ...reactHooks.configs.recommended.rules,
            ...eslintReact.configs.recommended.rules,
            ...(eslintNext.configs.recommended.rules as Record<string, unknown>),
            "react-refresh/only-export-components": ["warn", {allowConstantExport: true}],
            "no-console": ["warn", {allow: ["error"]}],
            "react-hooks/exhaustive-deps": "off",
            "newline-before-return": ["error"],
            "no-constant-condition": "error",
            "no-unused-expressions": "off",
            "@typescript-eslint/consistent-type-imports": "error",
            "@typescript-eslint/no-unused-vars": [
                "warn",
                {
                    args: "all",
                    argsIgnorePattern: "^_",
                    caughtErrors: "all",
                    caughtErrorsIgnorePattern: "^_",
                    destructuredArrayIgnorePattern: "^_",
                    varsIgnorePattern: "^_",
                    ignoreRestSiblings: true
                }
            ],
            "@typescript-eslint/no-explicit-any": "off",
            "@typescript-eslint/no-unused-expressions": "off",
            "@typescript-eslint/no-namespace": "off",
            "@typescript-eslint/no-empty-object-type": "off",
            "react/react-in-jsx-scope": "off",
            "react/prop-types": "off"
        }
    }
);
