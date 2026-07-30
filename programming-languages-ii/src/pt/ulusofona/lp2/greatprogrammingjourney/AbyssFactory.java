package pt.ulusofona.lp2.greatprogrammingjourney;

public class AbyssFactory {

    public static Abyss create(int id) {
        switch (id) {
            case 0:
                return new SyntaxErrorAbyss();
            case 1:
                return new LogicErrorAbyss();
            case 2:
                return new ExceptionAbyss();
            case 3:
                return new FileNotFoundAbyss();
            case 4:
                return new CrashAbyss();
            case 5:
                return new DuplicateCodeAbyss();
            case 6:
                return new SideEffectsAbyss();
            case 7:
                return new BlueScreenAbyss();
            case 8:
                return new InfiniteLoopAbyss();
            case 9:
                return new SegFaultAbyss();
            case 10:
                return new StackOverflowAbyss();
            case 20:
                return new LLMAbyss();
            default:
                return null;
        }
    }
}
