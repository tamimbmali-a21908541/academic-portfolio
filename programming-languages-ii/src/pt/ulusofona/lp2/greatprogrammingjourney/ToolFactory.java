package pt.ulusofona.lp2.greatprogrammingjourney;

public class ToolFactory {

    public static Tool create(int id) {
        switch (id) {
            case 0:
                return new InheritanceTool();
            case 1:
                return new FunctionalProgrammingTool();
            case 2:
                return new UnitTestsTool();
            case 3:
                return new ExceptionHandlingTool();
            case 4:
                return new IDETool();
            case 5:
                return new ProfessorHelpTool();
            default:
                return null;
        }
    }
}
