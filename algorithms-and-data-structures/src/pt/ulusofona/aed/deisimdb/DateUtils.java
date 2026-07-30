// pt.ulusofona.aed.deisimdb package to avoid package conflicts
package pt.ulusofona.aed.deisimdb;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Date utility class for operations on dates
 */
public class DateUtils {
    
    private static final String INPUT_FORMAT = "dd-MM-yyyy";
    private static final String OUTPUT_FORMAT = "yyyy-MM-dd";
    
    /**
     * Parse date string in dd-MM-yyyy or yyyy-MM-dd format
     * @param dateString string to parse
     * @return Date object or null if string is empty or invalid
     * @throws ParseException if string cannot be parsed in either format
     */
    public static Date parseDate(String dateString) throws ParseException {
        if (dateString == null || dateString.trim().isEmpty()) {
            return null;
        }
        
        SimpleDateFormat dateFormat = new SimpleDateFormat(INPUT_FORMAT);
        dateFormat.setLenient(false);
        try {
            return dateFormat.parse(dateString);
        } catch (ParseException e) {
            dateFormat = new SimpleDateFormat(OUTPUT_FORMAT);
            dateFormat.setLenient(false);
            return dateFormat.parse(dateString);
        }
    }
    
    /**
     * Format date in dd-MM-yyyy format for display in toString methods
     * @param date Date object to format
     * @return formatted date string or "n/a" if date is null
     */
    public static String formatDateForDisplay(Date date) {
        if (date == null) {
            return "n/a";
        }
        SimpleDateFormat dateFormat = new SimpleDateFormat(INPUT_FORMAT);
        return dateFormat.format(date);
    }
    
    /**
     * Format date in yyyy-MM-dd format for internal use
     * @param date Date object to format
     * @return formatted date string or "n/a" if date is null
     */
    public static String formatDate(Date date) {
        if (date == null) {
            return "n/a";
        }
        SimpleDateFormat dateFormat = new SimpleDateFormat(OUTPUT_FORMAT);
        return dateFormat.format(date);
    }
    
    /**
     * Extract year from a Date object
     * @param date Date object to extract year from
     * @return the year as an int
     */
    public static int getYear(Date date) {
        if (date == null) {
            return 0;
        }
        SimpleDateFormat yearFormat = new SimpleDateFormat("yyyy");
        return Integer.parseInt(yearFormat.format(date));
    }
    
    /**
     * Extract month from a Date object
     * @param date Date object to extract month from
     * @return the month as an int (1-12)
     */
    public static int getMonth(Date date) {
        if (date == null) {
            return 0;
        }
        SimpleDateFormat monthFormat = new SimpleDateFormat("MM");
        return Integer.parseInt(monthFormat.format(date));
    }
    
    /**
     * Convert Portuguese month name to month number
     * @param monthName month name in Portuguese
     * @return month number (1-12) or -1 if not recognized
     */
    public static int monthNameToNumber(String monthName) {
        if (monthName == null || monthName.trim().isEmpty()) {
            return -1;
        }
        
        monthName = monthName.trim().toLowerCase();
        
        switch (monthName) {
            case "janeiro": return 1;
            case "fevereiro": return 2;
            case "março": 
            case "marco": return 3;
            case "abril": return 4;
            case "maio": return 5;
            case "junho": return 6;
            case "julho": return 7;
            case "agosto": return 8;
            case "setembro": return 9;
            case "outubro": return 10;
            case "novembro": return 11;
            case "dezembro": return 12;
            default: 
                try {
                    return Integer.parseInt(monthName);
                } catch (NumberFormatException e) {
                    return -1;
                }
        }
    }
}