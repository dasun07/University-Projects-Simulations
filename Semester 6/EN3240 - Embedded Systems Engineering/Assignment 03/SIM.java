// Index : 180497C
// Name  : H. D. M. Premathilaka

/* On my honor, I have neither given nor received unauthorized aid on this assignment
 */

// Importing the required libraries
import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.Map.Entry;
import java.util.stream.Collectors;
import java.util.concurrent.atomic.AtomicInteger;

// Declaring the class SIM
public class SIM {
    // initializing the string variables
    static String allCompressedCodes = "";
    static String decompressedCodes = "";
    static String outString = "";

    // initializing the integer variables
    static int xForGeneral;
    static int yForRLE = 0;

    // initializing the list variables
    static List<String> codes = new ArrayList<String>();
    static List<String> compressions = new ArrayList<String>();

    // Initializing the mapping variables
    static HashMap<String, Integer> formatLengthConversion = new HashMap<String, Integer>();
    static LinkedHashMap<String, Integer> originalDict = new LinkedHashMap<String, Integer>();
    static LinkedHashMap<Integer, String> reversedDict = new LinkedHashMap<Integer, String>();
    static LinkedHashMap<String, Integer> codeMap = new LinkedHashMap<String, Integer>();

    // General Supplementary Functions
    // Integer to String Conversion
    public static String convertIntToStr(int existingIndex, int strSize) {
        String existingIndexStr = String.format("%3s", Integer.toBinaryString(existingIndex)).replace(' ', '0');
        return existingIndexStr;
    }

    // Left shifting the code cyclically
    public static String leftShiftLooping(String inputStr, int inputInt) {
        inputInt = inputInt % inputStr.length();
        return inputStr.substring(inputInt) + inputStr.substring(0, inputInt);
    }

    // Retrieving the occurences
    public static LinkedHashMap<String, Integer> retrieveHighestOccurences(LinkedHashMap<String, Integer> map) {
        AtomicInteger requiredEntryNum = new AtomicInteger();
        return map.entrySet().stream()
                .sorted(Entry.<String, Integer>comparingByValue().reversed())
                .limit(8)
                .collect(
                        Collectors.toMap(
                                e -> e.getKey(),
                                e -> requiredEntryNum.getAndIncrement(),
                                (k, v) -> {
                                    throw new IllegalStateException("Already existing key is " + k);
                                },
                                LinkedHashMap::new));
    }

    // Retrieving the compression format
    public static String retrieveCompressionFormat() {
        StringBuilder codeFormatUsed = new StringBuilder();

        for (int dummyNum = 0; dummyNum < 3; dummyNum++) {
            codeFormatUsed.append(allCompressedCodes.charAt(xForGeneral++));
        }
        return codeFormatUsed.toString();
    }

    // Bool to Char conversion and vice versa
    public static boolean charToBool(char inputArg) {
        return (inputArg == '1');
    }

    public static char boolToChar(boolean inputArg) {
        return (inputArg) ? '1' : '0';
    }

    // Supplementary Functions for code compression
    // Retrieving current RLE
    public static void retrieveCurrentRLE() {
        String compressionInstance = "";

        switch (yForRLE) {
            case 2:
                compressionInstance = "00";
                break;
            case 3:
                compressionInstance = "01";
                break;
            case 4:
                compressionInstance = "10";
                break;
            case 5:
                compressionInstance = "11";
                break;
        }
        allCompressedCodes = allCompressedCodes + "000" + compressionInstance;
    }

    // Function for bitmask based compression
    public static String bitMaskSearch(String code) {
        for (int dummyNum = 8; dummyNum < 16; dummyNum++) {
            String initialMask = String.format("%4s", Integer.toBinaryString(dummyNum)).replace(' ', '0');

            for (int secondDummyNum = 0; secondDummyNum < 29; secondDummyNum++) {
                StringBuilder codeStrBuilder = new StringBuilder();
                String leftZeroPadding = String.format("%" + (secondDummyNum + 4) + "s", initialMask).replace(' ', '0');
                String finalMask = String.format("%-" + 32 + "s", leftZeroPadding).replace(' ', '0');

                for (int thirdDummyNum = 0; thirdDummyNum < 32; thirdDummyNum++) {
                    codeStrBuilder.append(boolToChar(
                            charToBool(finalMask.charAt(thirdDummyNum)) ^ charToBool(code.charAt(thirdDummyNum))));
                }

                String relevantIns = codeStrBuilder.toString();

                if (originalDict.containsKey(relevantIns)) {
                    int existingIndex = originalDict.get(relevantIns);
                    String existingIndexStr = convertIntToStr(existingIndex, 3);
                    String diffPosition = String.format("%5s", Integer.toBinaryString(secondDummyNum)).replace(' ',
                            '0');
                    return diffPosition + initialMask + existingIndexStr;
                }
            }
        }
        return "";
    }

    // Searching for one bit differences
    public static String oneBitDiffSearch(String code) {
        for (int dummyNum = 0; dummyNum < code.length(); dummyNum++) {
            StringBuilder codeStrBuilder = new StringBuilder(code);
            codeStrBuilder.setCharAt(dummyNum, codeStrBuilder.charAt(dummyNum) == '0' ? '1' : '0');
            String relevantIns = codeStrBuilder.toString();
            if (originalDict.containsKey(relevantIns)) {
                String diffPosition = String.format("%5s", Integer.toBinaryString(dummyNum)).replace(' ', '0');
                int existingIndex = originalDict.get(relevantIns);
                String existingIndexStr = convertIntToStr(existingIndex, 3);
                return diffPosition + existingIndexStr;
            }
        }
        return "";
    }

    // Searching for consecutive two bit differences
    public static String consecTwoBitDiffSearch(String code) {
        for (int dummyNum = 0; dummyNum < code.length() - 1; dummyNum++) {
            StringBuilder codeStrBuilder = new StringBuilder(code);

            if (codeStrBuilder.charAt(dummyNum) == '0' && codeStrBuilder.charAt(dummyNum + 1) == '0') {
                codeStrBuilder.setCharAt(dummyNum, '1');
                codeStrBuilder.setCharAt(dummyNum + 1, '1');
            }

            else if (codeStrBuilder.charAt(dummyNum) == '0' && codeStrBuilder.charAt(dummyNum + 1) == '1') {
                codeStrBuilder.setCharAt(dummyNum, '1');
                codeStrBuilder.setCharAt(dummyNum + 1, '0');
            }

            else if (codeStrBuilder.charAt(dummyNum) == '1' && codeStrBuilder.charAt(dummyNum + 1) == '0') {
                codeStrBuilder.setCharAt(dummyNum, '0');
                codeStrBuilder.setCharAt(dummyNum + 1, '1');
            }

            else {
                codeStrBuilder.setCharAt(dummyNum, '0');
                codeStrBuilder.setCharAt(dummyNum + 1, '0');
            }

            String relevantIns = codeStrBuilder.toString();

            if (originalDict.containsKey(relevantIns)) {
                int existingIndex = originalDict.get(relevantIns);
                String existingIndexStr = convertIntToStr(existingIndex, 3);
                String diffPosition = String.format("%5s", Integer.toBinaryString(dummyNum)).replace(' ', '0');
                return diffPosition + existingIndexStr;
            }
        }
        return "";
    }

    // Searching for two bit difference, anywhere in the code
    public static String anyTwoBitDiffSearch(String code) {
        String leftMask = "10000000000000000000000000000000";

        for (int dummyNum = 0; dummyNum < 31; dummyNum++) {
            String leftMaskAfterShift = leftShiftLooping(leftMask, (32 - dummyNum));

            for (int secondDummyNum = dummyNum + 1; secondDummyNum < 32; secondDummyNum++) {
                StringBuilder maskStrBuilder = new StringBuilder();
                StringBuilder codeStrBuilder = new StringBuilder();

                String rightMaskAfterShift = leftShiftLooping(leftMask, (32 - secondDummyNum));

                for (int thirdDummyNum = 0; thirdDummyNum < 32; thirdDummyNum++) {
                    maskStrBuilder.append(boolToChar(charToBool(leftMaskAfterShift.charAt(thirdDummyNum))
                            ^ charToBool(rightMaskAfterShift.charAt(thirdDummyNum))));
                    codeStrBuilder.append(boolToChar(
                            charToBool(maskStrBuilder.charAt(thirdDummyNum)) ^ charToBool(code.charAt(thirdDummyNum))));
                }

                String relevantIns = codeStrBuilder.toString();

                if (originalDict.containsKey(relevantIns)) {
                    int existingIndex = originalDict.get(relevantIns);
                    String existingIndexStr = convertIntToStr(existingIndex, 3);

                    String leftDiffPosition = String.format("%5s", Integer.toBinaryString(dummyNum)).replace(' ', '0');
                    String rightDiffPosition = String.format("%5s", Integer.toBinaryString(secondDummyNum)).replace(' ',
                            '0');

                    return leftDiffPosition + rightDiffPosition + existingIndexStr;
                }
            }
        }

        return "";
    }

    // Supplementary functions for code decompression
    // Decompression - Direct Matching
    public static String reverseDM(String compressionInstance) {
        String existingIndex = compressionInstance.substring(0, compressionInstance.length());
        int existingIndexInt = Integer.parseInt(existingIndex, 2);

        // Checking if the index exists in the reversed dictionary
        if (reversedDict.containsKey(existingIndexInt)) {
            decompressedCodes = reversedDict.get(existingIndexInt);
        }
        outString = outString + decompressedCodes;
        return decompressedCodes;
    }

    // Decompression - No difference
    public static String noDiff(String compressionInstance) {
        decompressedCodes = compressionInstance;
        outString = outString + decompressedCodes;
        return decompressedCodes;
    }

    // Decompression - One Bit Difference
    public static String reverseOneBitDiffSearch(String compressionInstance) {
        String diffPosition = compressionInstance.substring(0, 5);
        String existingIndex = compressionInstance.substring(5, compressionInstance.length());
        int existingIndexInt = Integer.parseInt(existingIndex, 2);
        String relevantIns = "";

        // Checking if the index exists in the reversed dictionary
        if (reversedDict.containsKey(existingIndexInt)) {
            relevantIns = reversedDict.get(existingIndexInt);
        }

        int diffPositionInt = Integer.parseInt(diffPosition, 2);

        StringBuilder relevantInsStrBuilder = new StringBuilder(relevantIns);

        relevantInsStrBuilder.setCharAt(diffPositionInt,
                relevantInsStrBuilder.charAt(diffPositionInt) == '0' ? '1' : '0');

        decompressedCodes = relevantInsStrBuilder.toString();
        outString = outString + decompressedCodes;

        return decompressedCodes;
    }

    // Decompression - Two Bit Difference - Consecutive
    public static String reverseConsecTwoBitDiffSearch(String compressionInstance) {
        String diffPosition = compressionInstance.substring(0, 5);
        String existingIndex = compressionInstance.substring(5, compressionInstance.length());

        int existingIndexInt = Integer.parseInt(existingIndex, 2);

        String relevantIns = "";

        // Checking if the index exists in the reversed dictionary
        if (reversedDict.containsKey(existingIndexInt)) {
            relevantIns = reversedDict.get(existingIndexInt);
        }

        int diffPositionInt = Integer.parseInt(diffPosition, 2);

        StringBuilder relevantInsStrBuilder = new StringBuilder(relevantIns);

        // Replacing the two consecutive positions with correct bit values
        relevantInsStrBuilder.setCharAt(diffPositionInt,
                relevantInsStrBuilder.charAt(diffPositionInt) == '0' ? '1' : '0');

        relevantInsStrBuilder.setCharAt(diffPositionInt + 1,
                relevantInsStrBuilder.charAt(diffPositionInt + 1) == '0' ? '1' : '0');

        decompressedCodes = relevantInsStrBuilder.toString();

        outString = outString + decompressedCodes;

        return decompressedCodes;
    }

    // Decompression - Two Bit Difference - Anywhere
    public static String reverseAnyTwoBitDiffSearch(String compressionInstance) {
        String leftDiffPosition = compressionInstance.substring(0, 5);
        String rightDiffPosition = compressionInstance.substring(5, 10);

        String existingIndex = compressionInstance.substring(10, compressionInstance.length());
        int existingIndexInt = Integer.parseInt(existingIndex, 2);
        String relevantIns = "";

        // Checking if the index exists in the reversed dictionary
        if (reversedDict.containsKey(existingIndexInt)) {
            relevantIns = reversedDict.get(existingIndexInt);
        }

        int leftDiffPositionInt = Integer.parseInt(leftDiffPosition, 2);
        int rightDiffPositionInt = Integer.parseInt(rightDiffPosition, 2);

        StringBuilder relevantInsStrBuilder = new StringBuilder(relevantIns);

        // Replacing the corresponding left and right bits with suitable bit values
        relevantInsStrBuilder.setCharAt(leftDiffPositionInt,
                relevantInsStrBuilder.charAt(leftDiffPositionInt) == '0' ? '1' : '0');

        relevantInsStrBuilder.setCharAt(rightDiffPositionInt,
                relevantInsStrBuilder.charAt(rightDiffPositionInt) == '0' ? '1' : '0');

        decompressedCodes = relevantInsStrBuilder.toString();

        outString = outString + decompressedCodes;

        return decompressedCodes;
    }

    // Decompression - RLE
    public static String reverseRLE(String compressionInstance) {
        if (compressionInstance.equals("00")) {
            outString = outString + decompressedCodes;
        }

        else if (compressionInstance.equals("01")) {
            outString = outString + decompressedCodes + decompressedCodes;
        }

        else if (compressionInstance.equals("10")) {
            outString = outString + decompressedCodes + decompressedCodes + decompressedCodes;
        }

        else if (compressionInstance.equals("11")) {
            outString = outString + decompressedCodes + decompressedCodes + decompressedCodes + decompressedCodes;
        }
        return decompressedCodes;
    }

    // Decompression - Bit Mask
    public static String reverseBitMaskSearch(String compressionInstance) {
        String relevantIns = "";
        String diffPosition = compressionInstance.substring(0, 5);
        String extractedMask = compressionInstance.substring(5, 9);
        String existingIndex = compressionInstance.substring(9, compressionInstance.length());
        int existingIndexInt = Integer.parseInt(existingIndex, 2);

        // Checking if the index exists in the reversed dictionary
        if (reversedDict.containsKey(existingIndexInt)) {
            relevantIns = reversedDict.get(existingIndexInt);
        }

        int diffPositionInt = Integer.parseInt(diffPosition, 2);
        StringBuilder relevantInsStrBuilder = new StringBuilder();

        String leftZeroPadding = String.format("%" + (diffPositionInt + 4) + "s", extractedMask).replace(' ', '0');

        String finalMask = String.format("%-" + 32 + "s", leftZeroPadding).replace(' ', '0');

        // Building the code after looping through 32 times
        for (int dummyNum = 0; dummyNum < 32; dummyNum++) {
            relevantInsStrBuilder.append(
                    boolToChar(charToBool(finalMask.charAt(dummyNum)) ^ charToBool(relevantIns.charAt(dummyNum))));
        }

        decompressedCodes = relevantInsStrBuilder.toString();

        // output string generation
        outString = outString + decompressedCodes;

        return decompressedCodes;
    }

    // Compression Function
    public static void startCompression() {
        // Hardcoding input file name for compression
        String inputFilename = "original.txt";

        // Declaring other variables
        String previousCode = "invalid";
        String code;

        File inputFile = new File(inputFilename);

        // Error handling
        try {
            try (BufferedReader bufferedReader = new BufferedReader(new FileReader(inputFile))) {
                while ((code = bufferedReader.readLine()) != null) {
                    codes.add(code);

                    // Checking if the code exists in list
                    if (codeMap.containsKey(code)) {
                        codeMap.put(code, codeMap.get(code) + 1);
                    } else {
                        codeMap.put(code, 1);
                    }
                }
            }
        } catch (IOException errors) {
            errors.printStackTrace();
        }

        originalDict = retrieveHighestOccurences(codeMap);

        for (xForGeneral = 0; xForGeneral < codes.size(); xForGeneral++) {
            String compressedCode = "";
            code = codes.get(xForGeneral);

            if (code.equals(previousCode)) {
                yForRLE++;
            } else {
                if (yForRLE > 1) {
                    retrieveCurrentRLE();
                    yForRLE = 0;
                }

                // Direct Matching
                if (originalDict.containsKey(code)) {
                    int existingIndex = originalDict.get(code);
                    compressedCode = String.format("%3s", Integer.toBinaryString(existingIndex)).replace(' ', '0');

                    allCompressedCodes = allCompressedCodes + "101" + compressedCode;
                }

                // 1 Bit Mismatch
                else if (!((compressedCode = oneBitDiffSearch(code)).equals(""))) {
                    allCompressedCodes = allCompressedCodes + "010" + compressedCode;
                }

                // 2 Bit Mismatch - Successive
                else if (!((compressedCode = consecTwoBitDiffSearch(code)).equals(""))) {
                    allCompressedCodes = allCompressedCodes + "011" + compressedCode;
                }

                // Bit mask compression
                else if (!((compressedCode = bitMaskSearch(code)).equals(""))) {
                    allCompressedCodes = allCompressedCodes + "001" + compressedCode;
                }

                // 2 Bit Mismatch - Anywhere
                else if (!((compressedCode = anyTwoBitDiffSearch(code)).equals(""))) {
                    allCompressedCodes = allCompressedCodes + "100" + compressedCode;
                }

                // Initial binary
                else {
                    allCompressedCodes = allCompressedCodes + "110" + code;
                }

                yForRLE = 1;
                previousCode = code;
            }
        }

        String compressed = String
                .format("%-" + ((allCompressedCodes.length() / 32) + 1) * 32 + "s", allCompressedCodes)
                .replace(' ', '1');

        String outputString = compressed.replaceAll("(.{32})", "$1\n").trim();

        // Writing to cout.txt (Hardcoded name)
        // Error handling
        try {
            PrintStream outputStream = new PrintStream("cout.txt");
            System.setOut(outputStream);
        } catch (IOException error) {
            error.printStackTrace();
        }

        System.out.println(outputString);
        System.out.println("xxxx");

        Iterator dictIterator = originalDict.entrySet().iterator();

        while (dictIterator.hasNext()) {
            Map.Entry keyValuePair = (Map.Entry) dictIterator.next();
            System.out.println(keyValuePair.getKey());
        }
    }

    // Decompression Function
    public static void startDecompression() {
        // Declaring the required base variables
        // Name of the input file is hardcoded
        String inputFilename = "compressed.txt";
        String compressionInstance = "";
        int codeSize = 0;
        String decompDict = "";
        String decompFormat = "";

        // Resetting the xForGeneral variable as a precaution
        xForGeneral = 0;

        // Error Handling
        try {
            allCompressedCodes = new String(Files.readAllBytes(Paths.get(inputFilename)));
        } catch (IOException errors) {
            errors.printStackTrace();
        }

        decompDict = allCompressedCodes.substring(allCompressedCodes.lastIndexOf("x") + 1).trim();

        // Extracting the lines
        String compressedCodeEntries[] = decompDict.split("\\r?\\n");

        // Generating the dictionary for decompression
        for (xForGeneral = 0; xForGeneral < compressedCodeEntries.length; xForGeneral++) {
            reversedDict.put(xForGeneral, compressedCodeEntries[xForGeneral]);
        }
        // Resetting the general purpose variable
        xForGeneral = 0;

        // Creating a dictionary to map lengths and formats (order is given in
        // instructions)
        // RLE - 2
        formatLengthConversion.put("000", 2);
        // Bitmask - 12
        formatLengthConversion.put("001", 12);
        // 1 bit mismatch - 8
        formatLengthConversion.put("010", 8);
        // 2 bit consec mismatch - 8
        formatLengthConversion.put("011", 8);
        // 2 bit mismatch anywhere - 13
        formatLengthConversion.put("100", 13);
        // direct matching - 3
        formatLengthConversion.put("101", 3);
        // original - 32
        formatLengthConversion.put("110", 32);

        allCompressedCodes = allCompressedCodes.replaceAll("\\r\\n|\\r|\\n", "");

        // Determine the relevant format first
        while (allCompressedCodes.charAt(xForGeneral) != 'x') {
            // Format is encoded in the first three bits
            decompFormat = retrieveCompressionFormat();

            // Obtaining the code size based on the format
            if (formatLengthConversion.containsKey(decompFormat)) {
                codeSize = formatLengthConversion.get(decompFormat);
            }

            else {
                break;
            }

            // Retrieving the corresponding bits
            StringBuilder strBuilder = new StringBuilder();

            for (int dummyNum = 0; dummyNum < codeSize; dummyNum++) {
                strBuilder.append(allCompressedCodes.charAt(xForGeneral++));
            }

            compressionInstance = strBuilder.toString();

            // Obtaining the relevant format and feeding to the corresponding supplementary
            // functions
            if (decompFormat.equals("000")) {
                decompressedCodes = reverseRLE(compressionInstance);
            }

            else if (decompFormat.equals("001")) {
                decompressedCodes = reverseBitMaskSearch(compressionInstance);
            }

            else if (decompFormat.equals("010")) {
                decompressedCodes = reverseOneBitDiffSearch(compressionInstance);
            }

            else if (decompFormat.equals("011")) {
                decompressedCodes = reverseConsecTwoBitDiffSearch(compressionInstance);
            }

            else if (decompFormat.equals("100")) {
                decompressedCodes = reverseAnyTwoBitDiffSearch(compressionInstance);
            }

            else if (decompFormat.equals("101")) {
                decompressedCodes = reverseDM(compressionInstance);
            }

            else if (decompFormat.equals("110")) {
                decompressedCodes = noDiff(compressionInstance);
            }
        }

        // Writing decompressed codes to a file
        // Filename is hardcoded to dout.txt
        String outputString = outString.replaceAll("(.{32})", "$1\n").trim();

        // Error Handling
        try {
            PrintStream outputStream = new PrintStream("dout.txt");
            System.setOut(outputStream);
        } catch (IOException errors) {
            errors.printStackTrace();
        }
        System.out.println(outputString);
    }

    // Main Function
    public static void main(String[] args) {
        // Select compression or decompression using input
        String selectMode = args[0];

        if (selectMode.equals("1")) {
            startCompression();
        } else if (selectMode.equals("2")) {
            startDecompression();
        } else
            System.out.println("Invalid input. Please enter 1 for compression and 2 for decompression");
    }

}
