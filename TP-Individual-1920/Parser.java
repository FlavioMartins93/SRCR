import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import org.apache.poi.ss.usermodel.*;
import java.io.File;
import java.util.ArrayList;
import java.io.FileWriter;
import java.util.HashMap;

import java.awt.geom.Point2D;

public class Parser
{

    public static class Paragem {
        String gid;
        double latitude;
        double longitude;
        String tipoDeAbrigo;
        String abrigoComPublicidade;
        String operadora;
        String carreiras;
        String codigoDeRua;
        String nomeDeRua;
        String freguesia;

        public String toString() {
            return ("paragem(" + this.gid + ", " + this.latitude + ", " + this.longitude + ", " + 
                    this.tipoDeAbrigo + ", " + this.abrigoComPublicidade + ", " +
                    this.operadora +  ", [" +  this.carreiras + "] " + ").\n");
        }
    }

    public static String fixString(String s) {
        String news;
        if(s.length()==0) return "invalidValue";
        news = s.replaceAll("\\s+","");
        news = news.replaceAll(",","");
        news = news.replaceAll("'","");
        char c[] = news.toCharArray();
        c[0] = Character.toLowerCase(c[0]);
        String str = new String(c);
        return str;
    }

    public static void main(String[] args) throws IOException
    {
        
        HashMap<String,Paragem> paragens = new HashMap<String,Paragem>();

        /* Criação ficheiro destino com os dados */
        File destFile = new File("data.pl");
        destFile.createNewFile();

        /* Escritor para ficheiro */
        FileWriter fWrite = new FileWriter("data.pl");


        /* --- PARSE PARAGENS --- */
        // Input file, formato csv com todas as paragens
        String file = "paragens.csv";
        BufferedReader fileReader = null;
         
        //Delimiter used in CSV file
        final String DELIMITER = ";";
        try
        {
            String line = "";
            //Create the file reader
            fileReader = new BufferedReader(new FileReader(file));
            
            if ((line = fileReader.readLine()) != null) 
            {
                fWrite.write("%% ----- paragem ( Gid, Latitude, Longitude, TipoDeAbrigo, AbrigoComPublicidade, Operadora, [Carreira])\n");
            }

            int col;
            //Read the file line by line
            while ((line = fileReader.readLine()) != null) 
            {
                //fWrite.write("Paragem(");
                Paragem p = new Paragem();
                //Get all tokens available in line
                String[] tokens = line.split(DELIMITER);
                col = 1;
                for(String token : tokens)
                {
                    switch(col) {
                        case 1:     /* Id */
                            p.gid = fixString(token);
                            col++;
                            break;
                        case 2:     /* Latitude */
                            if (token.length()>0) p.latitude = Double.parseDouble(token);
                            else p.latitude = Double.parseDouble("-105000");  //Simular posição para o caso de erro encontrado no csv!
                            col++;
                            break;
                        case 3:     /* Longitude */
                            if (token.length()>0) p.longitude = Double.parseDouble(token);
                            else p.latitude = Double.parseDouble("-95000");   //Simular posição para o caso de erro encontrado no csv!                   
                            col++;
                            break;
                        case 5:     /* Tipo de abrigo */
                            p.tipoDeAbrigo = fixString(token);
                            col++;
                            break;
                        case 6:     /* Abrigo com publicidade */
                            p.abrigoComPublicidade = fixString(token);
                            col++;
                            break;
                        case 7:     /* Operadora */
                            p.operadora = fixString(token);
                            col++;
                            break;  
                        case 8:     /* Carreiras */
                            p.carreiras = token;
                            col++;
                            break;
                        case 9:     /* Codigo de Rua */
                            p.codigoDeRua = fixString(token);
                            col++;
                            break;                        
                        case 10:     /* Nome de Rua */
                            p.nomeDeRua = fixString(token);
                            col++;
                            break;                        
                        case 11:     /* Freguesia */
                            p.freguesia = fixString(token);
                            col++;
                            break;
                        default:
                            col++;
                            break;
                    }
                }
                paragens.put(p.gid,p);
                fWrite.write(p.toString());
            }
        } 
        catch (Exception e) {
            e.printStackTrace();
        } 
        finally
        {
            try {
                fileReader.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        try {
            /* --- PARSE CARREIRAS --- */
            // Creating a Workbook from an Excel file (.xls or .xlsx)
            Workbook workbook = WorkbookFactory.create(new File("carreiras.xlsx"));
            
            //fWrite.write("%% ----- Carreira (Id, [gid])\n");
            fWrite.write("%% ----- ligacao(Carreira, OrigemGid, DestinoGid, Distancia)\n");
            int r = 0;

            for(Sheet sheet : workbook) {    /* Iterar pelas várias Pags */
                String carreira = sheet.getSheetName();
                ArrayList<String> gids = new ArrayList<>();
                for (Row row : sheet) {      /* Iterar pelas várias linhas */
                    switch(r) {
                        case 0:
                            r++;
                            break;
                        default:
                            gids.add(String.valueOf((int)Double.parseDouble(row.getCell(0).toString())));
                            break;
                    }
                }
                for(int i=1; i<gids.size(); i++) {

                    double x1 = paragens.get(gids.get(i-1)).latitude;
                    double x2 = paragens.get(gids.get(i-1)).longitude;
                    double y1 = paragens.get(gids.get(i)).latitude;
                    double y2 = paragens.get(gids.get(i)).longitude;

                    double distance = Point2D.distance(x1, y1, x2, y2);
                    Integer dist = (int)distance;
                    fWrite.write("ligacao(" + carreira + ", " + gids.get(i-1) + ", " + 
                                             gids.get(i) + ", " + dist + ").\n");
                } 

                r = 0;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        fWrite.close();
    }
}