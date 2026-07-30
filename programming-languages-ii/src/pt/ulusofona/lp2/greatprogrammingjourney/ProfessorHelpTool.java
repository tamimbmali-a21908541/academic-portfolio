package pt.ulusofona.lp2.greatprogrammingjourney;

public class ProfessorHelpTool extends Tool {

    public ProfessorHelpTool() {
        super(5, "Ajuda do Professor");
    }

    @Override
    public String getImageName() {
        return "ajuda-professor.png";
    }

    @Override
    public boolean counters(Abyss abyss) {
        int abyssId = abyss.getId();
        return abyssId == 4 || abyssId == 7 || abyssId == 9 || abyssId == 20; // Crash, Blue Screen, Seg Fault, LLM
    }
}
