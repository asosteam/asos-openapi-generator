package com.asos.codegen.cmd;

import io.airlift.airline.Command;
import io.airlift.airline.Help;

import javax.inject.Inject;

@Command(name = "help", description = "Display help information about asos-codegen")
public class HelpCommand extends OpenApiGeneratorCommand {

    @Inject
    public Help help;

    @Override
    public void execute() {
        help.call();
    }
}
