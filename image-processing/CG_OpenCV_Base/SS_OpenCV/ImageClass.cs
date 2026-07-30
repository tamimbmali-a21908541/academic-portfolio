using System;
using System.Collections.Generic;
using System.Text;
using Emgu.CV.Structure;
using Emgu.CV;
using System.Linq;
using System.Drawing;
using System.Collections;

namespace CG_OpenCV
{
    class ImageClass
    {

        public static void Negative(Image<Bgr, byte> img)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                byte* dataPtr = (byte*)m.imageData.ToPointer(); // Pointer to the image
                byte blue, green, red;
                int width = img.Width;
                int height = img.Height;
                int nChan = m.nChannels; // number of channels - 3
                int x, y;
                int widthStep = m.widthStep;

                for (y = 0; y < height; y++)
                {
                    for (x = 0; x < width; x++)
                    {
                        blue = (dataPtr + nChan * x + widthStep * y)[0];
                        green = (dataPtr + nChan * x + widthStep * y)[1];
                        red = (dataPtr + nChan * x + widthStep * y)[2];

                        (dataPtr + nChan * x + widthStep * y)[0] = (byte)(255 - blue);
                        (dataPtr + nChan * x + widthStep * y)[1] = (byte)(255 - green);
                        (dataPtr + nChan * x + widthStep * y)[2] = (byte)(255 - red);
                    }
                }
            }
        }

        public static void ConvertToGray(Image<Bgr, byte> img)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                byte* dataPtr = (byte*)m.imageData.ToPointer(); // Pointer to the image
                byte blue, green, red, gray;
                int width = img.Width;
                int height = img.Height;
                int nChan = m.nChannels; // number of channels - 3
                int padding = m.widthStep - m.nChannels * m.width; // alinhament bytes (padding)
                int x, y;

                if (nChan == 3) // image in RGB
                {
                    for (y = 0; y < height; y++)
                    {
                        for (x = 0; x < width; x++)
                        {
                            blue = dataPtr[0];
                            green = dataPtr[1];
                            red = dataPtr[2];

                            gray = (byte)Math.Round(((int)blue + green + red) / 3.0);

                            dataPtr[0] = gray;
                            dataPtr[1] = gray;
                            dataPtr[2] = gray;

                            dataPtr += nChan;
                        }
                        dataPtr += padding;
                    }
                }
            }
        }

        public static void RedChannel(Image<Bgr, byte> img)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                byte* dataPtr = (byte*)m.imageData.ToPointer();

                int width = img.Width;
                int height = img.Height;
                int nChan = m.nChannels;
                int widthStep = m.widthStep;
                int x, y;

                if (nChan == 3)
                {
                    for (y = 0; y < height; y++)
                    {
                        for (x = 0; x < width; x++)
                        {
                            (dataPtr + nChan * x + widthStep * y)[0] = (dataPtr + nChan * x + widthStep * y)[2];
                            (dataPtr + nChan * x + widthStep * y)[1] = (dataPtr + nChan * x + widthStep * y)[2];
                        }
                    }
                }
            }
        }

        public static void BrightContrast(Image<Bgr, byte> img, int bright, double contrast)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                byte* dataPtr = (byte*)m.imageData.ToPointer();
                int blue = 0, green = 0, red = 0;

                int width = img.Width;
                int height = img.Height;
                int nChan = m.nChannels;
                int widthStep = m.widthStep;
                int x, y;

                if (nChan == 3)
                {
                    for (x = 0; x < width; x++)
                    {
                        for (y = 0; y < height; y++)
                        {
                            blue = (int)Math.Round(contrast * (dataPtr + nChan * x + widthStep * y)[0] + bright);
                            if (blue >= 255)
                            {
                                blue = 255;
                            }
                            else if (blue <= 0)
                            {
                                blue = 0;
                            }
                            (dataPtr + nChan * x + widthStep * y)[0] = (byte)blue;

                            green = (int)Math.Round(contrast * (dataPtr + nChan * x + widthStep * y)[1] + bright);
                            if (green >= 255)
                            {
                                green = 255;
                            }
                            else if (green <= 0)
                            {
                                green = 0;
                            }
                            (dataPtr + nChan * x + widthStep * y)[1] = (byte)green;

                            red = (int)Math.Round(contrast * (dataPtr + nChan * x + widthStep * y)[2] + bright);
                            if (red >= 255)
                            {
                                red = 255;
                            }
                            else if (red <= 0)
                            {
                                red = 0;
                            }
                            (dataPtr + nChan * x + widthStep * y)[2] = (byte)red;
                        }
                    }
                }
            }
        }

        public static void Translation(Image<Bgr, byte> img, Image<Bgr, byte> imgCopy, int dx, int dy)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                MIplImage mUndo = imgCopy.MIplImage;

                byte* dataPtrCopy = (byte*)mUndo.imageData.ToPointer();
                byte* auxDataPtrCopy;
                byte* dataPtr = (byte*)m.imageData.ToPointer();
                byte blue, green, red;
                int width = imgCopy.Width;
                int height = imgCopy.Height;
                int nChan = mUndo.nChannels;
                int widthStep = mUndo.widthStep;
                int padding = mUndo.widthStep - mUndo.nChannels * mUndo.width;

                int x_o, y_o;

                if (nChan == 3)
                {
                    for (int y = 0; y < height; y++)
                    {
                        for (int x = 0; x < width; x++)
                        {
                            x_o = x - dx;
                            y_o = y - dy;

                            auxDataPtrCopy = (byte*)(dataPtrCopy + y_o * widthStep + x_o * nChan);

                            if (x_o < width && x_o >= 0 && y_o < height && y_o >= 0)
                            {
                                blue = auxDataPtrCopy[0];
                                green = auxDataPtrCopy[1];
                                red = auxDataPtrCopy[2];
                            }
                            else
                            {
                                blue = green = red = 0;
                            }

                            (dataPtr + y * widthStep + x * nChan)[0] = blue;
                            (dataPtr + y * widthStep + x * nChan)[1] = green;
                            (dataPtr + y * widthStep + x * nChan)[2] = red;
                        }
                    }
                }

            }
        }

        public static void Rotation(Image<Bgr, byte> img, Image<Bgr, byte> imgCopy, float angle)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                MIplImage mUndo = imgCopy.MIplImage;

                byte* dataPtrCopy = (byte*)mUndo.imageData.ToPointer();
                byte* auxDataPtrCopy;
                byte* dataPtr = (byte*)m.imageData.ToPointer(); 
                byte blue, green, red;
                int width = imgCopy.Width;
                int height = imgCopy.Height;
                int nChan = mUndo.nChannels; 
                int widthStep = mUndo.widthStep;
                int padding = mUndo.widthStep - mUndo.nChannels * mUndo.width;

                int x_o, y_o;

                if (nChan == 3)
                {
                    for (int y = 0; y < height; y++)
                    {
                        for (int x = 0; x < width; x++)
                        {
                            x_o = (int)Math.Round((x - width / 2.0) * Math.Cos(angle) - (height / 2.0 - y) * Math.Sin(angle) + width / 2.0);
                            y_o = (int)Math.Round(height / 2.0 - (x - width / 2.0) * Math.Sin(angle) - (height / 2.0 - y) * Math.Cos(angle));

                            auxDataPtrCopy = (byte*)(dataPtrCopy + y_o * widthStep + x_o * nChan);

                            if (x_o < width && x_o >= 0 && y_o < height && y_o >= 0)
                            {
                                blue = auxDataPtrCopy[0];
                                green = auxDataPtrCopy[1];
                                red = auxDataPtrCopy[2];
                            }
                            else
                            {
                                blue = green = red = 0;
                            }

                            (dataPtr + y * widthStep + x * nChan)[0] = blue;
                            (dataPtr + y * widthStep + x * nChan)[1] = green;
                            (dataPtr + y * widthStep + x * nChan)[2] = red;
                        }
                    }
                }

            }
        }

        public static void Scale(Image<Bgr, byte> img, Image<Bgr, byte> imgCopy, float scaleFactor)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                MIplImage mUndo = imgCopy.MIplImage;

                byte* dataPtrCopy = (byte*)mUndo.imageData.ToPointer();
                byte* auxDataPtrCopy;
                byte* dataPtr = (byte*)m.imageData.ToPointer();
                byte blue, green, red;
                int width = imgCopy.Width;
                int height = imgCopy.Height;
                int nChan = mUndo.nChannels;
                int widthStep = mUndo.widthStep;
                int padding = mUndo.widthStep - mUndo.nChannels * mUndo.width;
                int x_o, y_o;

                if (nChan == 3)
                {
                    for (int y = 0; y < height; y++)
                    {
                        for (int x = 0; x < width; x++)
                        {
                            x_o = (int)Math.Round(x / scaleFactor);
                            y_o = (int)Math.Round(y / scaleFactor);

                            auxDataPtrCopy = (byte*)(dataPtrCopy + y_o * widthStep + x_o * nChan);

                            if (x_o < width && x_o >= 0 && y_o < height && y_o >= 0)
                            {
                                blue = auxDataPtrCopy[0];
                                green = auxDataPtrCopy[1];
                                red = auxDataPtrCopy[2];
                            }
                            else
                            {
                                blue = green = red = 0;
                            }

                            (dataPtr + y * widthStep + x * nChan)[0] = blue;
                            (dataPtr + y * widthStep + x * nChan)[1] = green;
                            (dataPtr + y * widthStep + x * nChan)[2] = red;
                        }
                    }
                }

            }
        }

        public static void Scale_point_xy(Image<Bgr, byte> img, Image<Bgr, byte> imgCopy, float scaleFactor, int centerX, int centerY)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                MIplImage copia = imgCopy.MIplImage;
                byte* dataPtrDestino = (byte*)m.imageData.ToPointer();
                byte* dataPtrCopia = (byte*)copia.imageData.ToPointer();

                int width = img.Width;
                int height = img.Height;
                int nChan = m.nChannels;
                int widthStep = m.widthStep;
                int x, y, xDest, yDest;

                if (nChan == 3)
                {
                    for (x = 0; x < width; x++)
                    {
                        for (y = 0; y < height; y++)
                        {
                            xDest = (int)Math.Round(centerX + (x - width / 2) / scaleFactor);
                            yDest = (int)Math.Round(centerY + (y - height / 2) / scaleFactor);

                            if ((xDest >= width || xDest < 0) || (yDest >= height || yDest < 0))
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[0] = 0;
                                (dataPtrDestino + nChan * x + widthStep * y)[1] = 0;
                                (dataPtrDestino + nChan * x + widthStep * y)[2] = 0;
                            }
                            else
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[0] = (dataPtrCopia + nChan * xDest + widthStep * yDest)[0];
                                (dataPtrDestino + nChan * x + widthStep * y)[1] = (dataPtrCopia + nChan * xDest + widthStep * yDest)[1];
                                (dataPtrDestino + nChan * x + widthStep * y)[2] = (dataPtrCopia + nChan * xDest + widthStep * yDest)[2];
                            }
                        }
                    }
                }
            }
        }

        public static void Mean(Image<Bgr, byte> img, Image<Bgr, byte> imgCopy)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                MIplImage mUndo = imgCopy.MIplImage;

                byte* dataPtrCopy = (byte*)mUndo.imageData.ToPointer();
                byte* dataPtr = (byte*)m.imageData.ToPointer();
                int width = imgCopy.Width;
                int height = imgCopy.Height;
                int nChan = mUndo.nChannels;
                int widthStep = mUndo.widthStep;
                int padding = mUndo.widthStep - mUndo.nChannels * mUndo.width;

                if (nChan == 3)
                {
                    for (int y = 1; y < height - 1; y++)
                    {
                        for (int x = 1; x < width - 1; x++)
                        {

                            (dataPtr + y * widthStep + x * nChan)[0] = (byte)(Math.Round(((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0] +
                                (dataPtrCopy + (y - 1) * widthStep + x * nChan)[0] +
                                (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0] +
                                (dataPtrCopy + y * widthStep + (x - 1) * nChan)[0] +
                                (dataPtrCopy + y * widthStep + x * nChan)[0] +
                                (dataPtrCopy + y * widthStep + (x + 1) * nChan)[0] +
                                (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0] +
                                (dataPtrCopy + (y + 1) * widthStep + x * nChan)[0] +
                                (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0]) / 9.0));

                            (dataPtr + y * widthStep + x * nChan)[1] = (byte)(Math.Round(((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1] +
                                (dataPtrCopy + (y - 1) * widthStep + x * nChan)[1] +
                                (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1] +
                                (dataPtrCopy + y * widthStep + (x - 1) * nChan)[1] +
                                (dataPtrCopy + y * widthStep + x * nChan)[1] +
                                (dataPtrCopy + y * widthStep + (x + 1) * nChan)[1] +
                                (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1] +
                                (dataPtrCopy + (y + 1) * widthStep + x * nChan)[1] +
                                (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1]) / 9.0));

                            (dataPtr + y * widthStep + x * nChan)[2] = (byte)(Math.Round(((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2] +
                                (dataPtrCopy + (y - 1) * widthStep + x * nChan)[2] +
                                (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2] +
                                (dataPtrCopy + y * widthStep + (x - 1) * nChan)[2] +
                                (dataPtrCopy + y * widthStep + x * nChan)[2] +
                                (dataPtrCopy + y * widthStep + (x + 1) * nChan)[2] +
                                (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2] +
                                (dataPtrCopy + (y + 1) * widthStep + x * nChan)[2] +
                                (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2]) / 9.0));

                        }
                    }
                    for (int y = 1; y < height - 1; y++)
                    {
                        (dataPtr + y * widthStep)[0] = (byte)(Math.Round((2 * (dataPtrCopy + (y - 1) * widthStep)[0] +
                                (dataPtrCopy + (y - 1) * widthStep + nChan)[0] +
                                2 * (dataPtrCopy + y * widthStep)[0] +
                                (dataPtrCopy + y * widthStep + nChan)[0] +
                                2 * (dataPtrCopy + (y + 1) * widthStep)[0] +
                                (dataPtrCopy + (y + 1) * widthStep + nChan)[0]) / 9.0));

                        (dataPtr + y * widthStep + (width - 1) * nChan)[0] = (byte)(Math.Round(((dataPtrCopy + (y - 1) * widthStep + (width - 2) * nChan)[0] +
                                2 * (dataPtrCopy + (y - 1) * widthStep + (width - 1) * nChan)[0] +
                                (dataPtrCopy + y * widthStep + (width - 2) * nChan)[0] +
                                2 * (dataPtrCopy + y * widthStep + (width - 1) * nChan)[0] +
                                (dataPtrCopy + (y + 1) * widthStep + (width - 2) * nChan)[0] +
                                2 * (dataPtrCopy + (y + 1) * widthStep + (width - 1) * nChan)[0]) / 9.0));

                        (dataPtr + y * widthStep)[1] = (byte)(Math.Round((2 * (dataPtrCopy + (y - 1) * widthStep)[1] +
                                (dataPtrCopy + (y - 1) * widthStep + nChan)[1] +
                                2 * (dataPtrCopy + y * widthStep)[1] +
                                (dataPtrCopy + y * widthStep + nChan)[1] +
                                2 * (dataPtrCopy + (y + 1) * widthStep)[1] +
                                (dataPtrCopy + (y + 1) * widthStep + nChan)[1]) / 9.0));

                        (dataPtr + y * widthStep + (width - 1) * nChan)[1] = (byte)(Math.Round(((dataPtrCopy + (y - 1) * widthStep + (width - 2) * nChan)[1] +
                                2 * (dataPtrCopy + (y - 1) * widthStep + (width - 1) * nChan)[1] +
                                (dataPtrCopy + y * widthStep + (width - 2) * nChan)[1] +
                                2 * (dataPtrCopy + y * widthStep + (width - 1) * nChan)[1] +
                                (dataPtrCopy + (y + 1) * widthStep + (width - 2) * nChan)[1] +
                                2 * (dataPtrCopy + (y + 1) * widthStep + (width - 1) * nChan)[1]) / 9.0));

                        (dataPtr + y * widthStep)[2] = (byte)(Math.Round((2 * (dataPtrCopy + (y - 1) * widthStep)[2] +
                                (dataPtrCopy + (y - 1) * widthStep + nChan)[2] +
                                2 * (dataPtrCopy + y * widthStep)[2] +
                                (dataPtrCopy + y * widthStep + nChan)[2] +
                                2 * (dataPtrCopy + (y + 1) * widthStep)[2] +
                                (dataPtrCopy + (y + 1) * widthStep + nChan)[2]) / 9.0));

                        (dataPtr + y * widthStep + (width - 1) * nChan)[2] = (byte)(Math.Round(((dataPtrCopy + (y - 1) * widthStep + (width - 2) * nChan)[2] +
                                2 * (dataPtrCopy + (y - 1) * widthStep + (width - 1) * nChan)[2] +
                                (dataPtrCopy + y * widthStep + (width - 2) * nChan)[2] +
                                2 * (dataPtrCopy + y * widthStep + (width - 1) * nChan)[2] +
                                (dataPtrCopy + (y + 1) * widthStep + (width - 2) * nChan)[2] +
                                2 * (dataPtrCopy + (y + 1) * widthStep + (width - 1) * nChan)[2]) / 9.0));
                    }

                    for (int x = 1; x < width - 1; x++)
                    {
                        (dataPtr + x * nChan)[0] = (byte)(Math.Round((2 * (dataPtrCopy + (x - 1) * nChan)[0] +
                                2 * (dataPtrCopy + x * nChan)[0] +
                                2 * (dataPtrCopy + (x + 1) * nChan)[0] +
                                (dataPtrCopy + widthStep + (x - 1) * nChan)[0] +
                                (dataPtrCopy + widthStep + x * nChan)[0] +
                                (dataPtrCopy + widthStep + (x + 1) * nChan)[0]) / 9.0));

                        (dataPtr + (height - 1) * widthStep + x * nChan)[0] = (byte)(Math.Round(((dataPtrCopy + (height - 2) * widthStep + (x - 1) * nChan)[0] +
                                (dataPtrCopy + (height - 2) * widthStep + x * nChan)[0] +
                                (dataPtrCopy + (height - 2) * widthStep + (x + 1) * nChan)[0] +
                                2 * (dataPtrCopy + (height - 1) * widthStep + (x - 1) * nChan)[0] +
                                2 * (dataPtrCopy + (height - 1) * widthStep + x * nChan)[0] +
                                2 * (dataPtrCopy + (height - 1) * widthStep + (x + 1) * nChan)[0]) / 9.0));

                        (dataPtr + x * nChan)[1] = (byte)(Math.Round((2 * (dataPtrCopy + (x - 1) * nChan)[1] +
                                2 * (dataPtrCopy + x * nChan)[1] +
                                2 * (dataPtrCopy + (x + 1) * nChan)[1] +
                                (dataPtrCopy + widthStep + (x - 1) * nChan)[1] +
                                (dataPtrCopy + widthStep + x * nChan)[1] +
                                (dataPtrCopy + widthStep + (x + 1) * nChan)[1]) / 9.0));

                        (dataPtr + (height - 1) * widthStep + x * nChan)[1] = (byte)(Math.Round(((dataPtrCopy + (height - 2) * widthStep + (x - 1) * nChan)[1] +
                                (dataPtrCopy + (height - 2) * widthStep + x * nChan)[1] +
                                (dataPtrCopy + (height - 2) * widthStep + (x + 1) * nChan)[1] +
                                2 * (dataPtrCopy + (height - 1) * widthStep + (x - 1) * nChan)[1] +
                                2 * (dataPtrCopy + (height - 1) * widthStep + x * nChan)[1] +
                                2 * (dataPtrCopy + (height - 1) * widthStep + (x + 1) * nChan)[1]) / 9.0));

                        (dataPtr + x * nChan)[2] = (byte)(Math.Round((2 * (dataPtrCopy + (x - 1) * nChan)[2] +
                                2 * (dataPtrCopy + x * nChan)[2] +
                                2 * (dataPtrCopy + (x + 1) * nChan)[2] +
                                (dataPtrCopy + widthStep + (x - 1) * nChan)[2] +
                                (dataPtrCopy + widthStep + x * nChan)[2] +
                                (dataPtrCopy + widthStep + (x + 1) * nChan)[2]) / 9.0));

                        (dataPtr + (height - 1) * widthStep + x * nChan)[2] = (byte)(Math.Round(((dataPtrCopy + (height - 2) * widthStep + (x - 1) * nChan)[2] +
                                (dataPtrCopy + (height - 2) * widthStep + x * nChan)[2] +
                                (dataPtrCopy + (height - 2) * widthStep + (x + 1) * nChan)[2] +
                                2 * (dataPtrCopy + (height - 1) * widthStep + (x - 1) * nChan)[2] +
                                2 * (dataPtrCopy + (height - 1) * widthStep + x * nChan)[2] +
                                2 * (dataPtrCopy + (height - 1) * widthStep + (x + 1) * nChan)[2]) / 9.0));
                    }
                    //Canto Superior Esquerdo
                    (dataPtr)[0] = (byte)(Math.Round((4 * (dataPtrCopy)[0] +
                        2 * (dataPtrCopy + nChan)[0] +
                        2 * (dataPtrCopy + widthStep)[0] +
                        (dataPtrCopy + widthStep + nChan)[0]) / 9.0));

                    (dataPtr)[1] = (byte)(Math.Round((4 * (dataPtrCopy)[1] +
                        2 * (dataPtrCopy + nChan)[1] +
                        2 * (dataPtrCopy + widthStep)[1] +
                        (dataPtrCopy + widthStep + nChan)[1]) / 9.0));

                    (dataPtr)[2] = (byte)(Math.Round((4 * (dataPtrCopy)[2] +
                        2 * (dataPtrCopy + nChan)[2] +
                        2 * (dataPtrCopy + widthStep)[2] +
                        (dataPtrCopy + widthStep + nChan)[2]) / 9.0));
                    //Canto Superior Direito
                    (dataPtr + (width - 1) * nChan)[0] = (byte)(Math.Round((2 * (dataPtrCopy + (width - 2) * nChan)[0] +
                        4 * (dataPtrCopy + (width - 1) * nChan)[0] +
                        (dataPtrCopy + (width - 2) * nChan + widthStep)[0] +
                        2 * (dataPtrCopy + (width - 1) * nChan + widthStep)[0]) / 9.0));

                    (dataPtr + (width - 1) * nChan)[1] = (byte)(Math.Round((2 * (dataPtrCopy + (width - 2) * nChan)[1] +
                        4 * (dataPtrCopy + (width - 1) * nChan)[1] +
                        (dataPtrCopy + (width - 2) * nChan + widthStep)[1] +
                        2 * (dataPtrCopy + (width - 1) * nChan + widthStep)[1]) / 9.0));

                    (dataPtr + (width - 1) * nChan)[2] = (byte)(Math.Round((2 * (dataPtrCopy + (width - 2) * nChan)[2] +
                        4 * (dataPtrCopy + (width - 1) * nChan)[2] +
                        (dataPtrCopy + (width - 2) * nChan + widthStep)[2] +
                        2 * (dataPtrCopy + (width - 1) * nChan + widthStep)[2]) / 9.0));
                    //Canto Inferior Esquerdo
                    (dataPtr + (height - 1) * widthStep)[0] = (byte)(Math.Round((2 * (dataPtrCopy + (height - 2) * widthStep)[0] +
                        (dataPtrCopy + (height - 2) * widthStep + nChan)[0] +
                        4 * (dataPtrCopy + (height - 1) * widthStep)[0] +
                        2 * (dataPtrCopy + (height - 1) * widthStep + nChan)[0]) / 9.0));

                    (dataPtr + (height - 1) * widthStep)[1] = (byte)(Math.Round((2 * (dataPtrCopy + (height - 2) * widthStep)[1] +
                        (dataPtrCopy + (height - 2) * widthStep + nChan)[1] +
                        4 * (dataPtrCopy + (height - 1) * widthStep)[1] +
                        2 * (dataPtrCopy + (height - 1) * widthStep + nChan)[1]) / 9.0));

                    (dataPtr + (height - 1) * widthStep)[2] = (byte)(Math.Round((2 * (dataPtrCopy + (height - 2) * widthStep)[2] +
                        (dataPtrCopy + (height - 2) * widthStep + nChan)[2] +
                        4 * (dataPtrCopy + (height - 1) * widthStep)[2] +
                        2 * (dataPtrCopy + (height - 1) * widthStep + nChan)[2]) / 9.0));
                    //Canto Inferior Direito
                    (dataPtr + (height - 1) * widthStep + (width - 1) * nChan)[0] = (byte)(Math.Round(((dataPtrCopy + (height - 2) * widthStep + (width - 2) * nChan)[0] +
                        2 * (dataPtrCopy + (height - 2) * widthStep + (width - 1) * nChan)[0] +
                        2 * (dataPtrCopy + (height - 1) * widthStep + (width - 2) * nChan)[0] +
                        4 * (dataPtrCopy + (height - 1) * widthStep + (width - 1) * nChan)[0]) / 9.0));

                    (dataPtr + (height - 1) * widthStep + (width - 1) * nChan)[1] = (byte)(Math.Round(((dataPtrCopy + (height - 2) * widthStep + (width - 2) * nChan)[1] +
                        2 * (dataPtrCopy + (height - 2) * widthStep + (width - 1) * nChan)[1] +
                        2 * (dataPtrCopy + (height - 1) * widthStep + (width - 2) * nChan)[1] +
                        4 * (dataPtrCopy + (height - 1) * widthStep + (width - 1) * nChan)[1]) / 9.0));

                    (dataPtr + (height - 1) * widthStep + (width - 1) * nChan)[2] = (byte)(Math.Round(((dataPtrCopy + (height - 2) * widthStep + (width - 2) * nChan)[2] +
                        2 * (dataPtrCopy + (height - 2) * widthStep + (width - 1) * nChan)[2] +
                        2 * (dataPtrCopy + (height - 1) * widthStep + (width - 2) * nChan)[2] +
                        4 * (dataPtrCopy + (height - 1) * widthStep + (width - 1) * nChan)[2]) / 9.0));
                }
            }
        }

        public static void NonUniform(Image<Bgr, byte> img, Image<Bgr, byte> imgCopy, float[,] matrix, float matrixWeight)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                MIplImage copia = imgCopy.MIplImage;

                byte* dataPtrDestino = (byte*)m.imageData.ToPointer();
                byte* dataPtrCopia = (byte*)copia.imageData.ToPointer();
                int width = img.Width;
                int height = img.Height;
                int nChan = m.nChannels;
                int widthStep = m.widthStep;
                int x, y;
                double xB, xG, xR;

                if (nChan == 3)
                {
                    //Centro
                    for (x = 1; x < width - 1; x++)
                    {
                        for (y = 1; y < height - 1; y++)
                        {
                            xB = Math.Round((((dataPtrCopia + nChan * (x - 1) + widthStep * (y - 1))[0] * matrix[0, 0]) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (y))[0] * matrix[1, 0]) + ((dataPtrCopia + nChan * (x) + widthStep * (y - 1))[0] * matrix[0, 1]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (y - 1))[0] * matrix[0, 2]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (y))[0] * matrix[1, 2]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (y + 1))[0] * matrix[2, 2]) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (y + 1))[0] * matrix[2, 0]) + ((dataPtrCopia + nChan * (x) + widthStep * (y + 1))[0] * matrix[2, 1]) + ((dataPtrCopia + nChan * (x) + widthStep * (y))[0] * matrix[1, 1])) / matrixWeight);
                            xG = Math.Round((((dataPtrCopia + nChan * (x - 1) + widthStep * (y - 1))[1] * matrix[0, 0]) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (y))[1] * matrix[1, 0]) + ((dataPtrCopia + nChan * (x) + widthStep * (y - 1))[1] * matrix[0, 1]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (y - 1))[1] * matrix[0, 2]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (y))[1] * matrix[1, 2]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (y + 1))[1] * matrix[2, 2]) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (y + 1))[1] * matrix[2, 0]) + ((dataPtrCopia + nChan * (x) + widthStep * (y + 1))[1] * matrix[2, 1]) + ((dataPtrCopia + nChan * (x) + widthStep * (y))[1] * matrix[1, 1])) / matrixWeight);
                            xR = Math.Round((((dataPtrCopia + nChan * (x - 1) + widthStep * (y - 1))[2] * matrix[0, 0]) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (y))[2] * matrix[1, 0]) + ((dataPtrCopia + nChan * (x) + widthStep * (y - 1))[2] * matrix[0, 1]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (y - 1))[2] * matrix[0, 2]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (y))[2] * matrix[1, 2]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (y + 1))[2] * matrix[2, 2]) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (y + 1))[2] * matrix[2, 0]) + ((dataPtrCopia + nChan * (x) + widthStep * (y + 1))[2] * matrix[2, 1]) + ((dataPtrCopia + nChan * (x) + widthStep * (y))[2] * matrix[1, 1])) / matrixWeight);

                            if (xB > 255)
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[0] = 255;
                            }
                            else if (xB < 0)
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[0] = 0;
                            }
                            else
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[0] = (byte)xB;
                            }

                            if (xG > 255)
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[1] = 255;
                            }
                            else if (xG < 0)
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[1] = 0;
                            }
                            else
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[1] = (byte)xG;
                            }

                            if (xR > 255)
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[2] = 255;
                            }
                            else if (xR < 0)
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[2] = 0;
                            }
                            else
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[2] = (byte)xR;
                            }
                        }
                    }

                    //Canto Superior Esquerdo
                    xB = Math.Round((((dataPtrCopia)[0] * (matrix[0, 0] + matrix[0, 1] + matrix[1, 0] + matrix[1, 1])) + ((dataPtrCopia + widthStep)[0] * (matrix[2, 0] + matrix[2, 1])) + ((dataPtrCopia + nChan)[0] * (matrix[0, 2] + matrix[1, 2])) + (dataPtrCopia + nChan + widthStep)[0] * matrix[2, 2]) / matrixWeight);
                    xG = Math.Round((((dataPtrCopia)[1] * (matrix[0, 0] + matrix[0, 1] + matrix[1, 0] + matrix[1, 1])) + ((dataPtrCopia + widthStep)[1] * (matrix[2, 0] + matrix[2, 1])) + ((dataPtrCopia + nChan)[1] * (matrix[0, 2] + matrix[1, 2])) + (dataPtrCopia + nChan + widthStep)[1] * matrix[2, 2]) / matrixWeight);
                    xR = Math.Round((((dataPtrCopia)[2] * (matrix[0, 0] + matrix[0, 1] + matrix[1, 0] + matrix[1, 1])) + ((dataPtrCopia + widthStep)[2] * (matrix[2, 0] + matrix[2, 1])) + ((dataPtrCopia + nChan)[2] * (matrix[0, 2] + matrix[1, 2])) + (dataPtrCopia + nChan + widthStep)[2] * matrix[2, 2]) / matrixWeight);

                    if (xB > 255)
                    {
                        (dataPtrDestino)[0] = 255;
                    }
                    else if (xB < 0)
                    {
                        (dataPtrDestino)[0] = 0;
                    }
                    else
                    {
                        (dataPtrDestino)[0] = (byte)xB;
                    }

                    if (xG > 255)
                    {
                        (dataPtrDestino)[1] = 255;
                    }
                    else if (xG < 0)
                    {
                        (dataPtrDestino)[1] = 0;
                    }
                    else
                    {
                        (dataPtrDestino)[1] = (byte)xG;
                    }

                    if (xR > 255)
                    {
                        (dataPtrDestino)[2] = 255;
                    }
                    else if (xR < 0)
                    {
                        (dataPtrDestino)[2] = 0;
                    }
                    else
                    {
                        (dataPtrDestino)[2] = (byte)xR;
                    }

                    //Canto Superior Direito
                    xB = Math.Round(((((dataPtrCopia + nChan * (width - 1))[0] * (matrix[0, 1] + matrix[0, 2] + matrix[1, 1] + matrix[1, 2]))) + (((dataPtrCopia + nChan * (width - 1) + widthStep)[0] * (matrix[2, 1] + matrix[2, 2]))) + (((dataPtrCopia + nChan * (width - 2))[0] * (matrix[0, 0] + matrix[1, 0]))) + (dataPtrCopia + nChan * (width - 2) + widthStep)[0] * matrix[2, 0]) / matrixWeight);
                    xG = Math.Round(((((dataPtrCopia + nChan * (width - 1))[1] * (matrix[0, 1] + matrix[0, 2] + matrix[1, 1] + matrix[1, 2]))) + (((dataPtrCopia + nChan * (width - 1) + widthStep)[1] * (matrix[2, 1] + matrix[2, 2]))) + (((dataPtrCopia + nChan * (width - 2))[1] * (matrix[0, 0] + matrix[1, 0]))) + (dataPtrCopia + nChan * (width - 2) + widthStep)[1] * matrix[2, 0]) / matrixWeight);
                    xR = Math.Round(((((dataPtrCopia + nChan * (width - 1))[2] * (matrix[0, 1] + matrix[0, 2] + matrix[1, 1] + matrix[1, 2]))) + (((dataPtrCopia + nChan * (width - 1) + widthStep)[2] * (matrix[2, 1] + matrix[2, 2]))) + (((dataPtrCopia + nChan * (width - 2))[2] * (matrix[0, 0] + matrix[1, 0]))) + (dataPtrCopia + nChan * (width - 2) + widthStep)[2] * matrix[2, 0]) / matrixWeight);

                    if (xB > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1))[0] = 255;
                    }
                    else if (xB < 0)
                    {
                        (dataPtrDestino + nChan * (width - 1))[0] = 0;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1))[0] = (byte)xB;
                    }

                    if (xG > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1))[1] = 255;
                    }
                    else if (xG < 0)
                    {
                        (dataPtrDestino + nChan * (width - 1))[1] = 0;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1))[1] = (byte)xG;
                    }

                    if (xR > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1))[2] = 255;
                    }
                    else if (xR < 0)
                    {
                        (dataPtrDestino + nChan * (width - 1))[2] = 0;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1))[2] = (byte)xR;
                    }

                    //Canto Inferior Esquerdo
                    xB = (byte)Math.Round(((((dataPtrCopia + widthStep * (height - 1))[0] * (matrix[1, 0] + matrix[2, 0] + matrix[1, 1] + matrix[2, 1]))) + (((dataPtrCopia + widthStep * (height - 2))[0] * (matrix[0, 0] + matrix[0, 1]))) + (((dataPtrCopia + nChan + widthStep * (height - 1))[0] * (matrix[1, 2] + matrix[2, 2]))) + (dataPtrCopia + nChan + widthStep * (height - 2))[0] + matrix[0, 2]) / matrixWeight);
                    xG = (byte)Math.Round(((((dataPtrCopia + widthStep * (height - 1))[1] * (matrix[1, 0] + matrix[2, 0] + matrix[1, 1] + matrix[2, 1]))) + (((dataPtrCopia + widthStep * (height - 2))[1] * (matrix[0, 0] + matrix[0, 1]))) + (((dataPtrCopia + nChan + widthStep * (height - 1))[1] * (matrix[1, 2] + matrix[2, 2]))) + (dataPtrCopia + nChan + widthStep * (height - 2))[1] + matrix[0, 2]) / matrixWeight);
                    xR = (byte)Math.Round(((((dataPtrCopia + widthStep * (height - 1))[2] * (matrix[1, 0] + matrix[2, 0] + matrix[1, 1] + matrix[2, 1]))) + (((dataPtrCopia + widthStep * (height - 2))[2] * (matrix[0, 0] + matrix[0, 1]))) + (((dataPtrCopia + nChan + widthStep * (height - 1))[2] * (matrix[1, 2] + matrix[2, 2]))) + (dataPtrCopia + nChan + widthStep * (height - 2))[2] + matrix[0, 2]) / matrixWeight);

                    if (xB > 255)
                    {
                        (dataPtrDestino + widthStep * (height - 1))[0] = 255;
                    }
                    else if (xB < 0)
                    {
                        (dataPtrDestino + widthStep * (height - 1))[0] = 0;
                    }
                    else
                    {
                        (dataPtrDestino + widthStep * (height - 1))[0] = (byte)xB;
                    }

                    if (xG > 255)
                    {
                        (dataPtrDestino + widthStep * (height - 1))[1] = 255;
                    }
                    else if (xG < 0)
                    {
                        (dataPtrDestino + widthStep * (height - 1))[1] = 0;
                    }
                    else
                    {
                        (dataPtrDestino + widthStep * (height - 1))[1] = (byte)xG;
                    }

                    if (xR > 255)
                    {
                        (dataPtrDestino + widthStep * (height - 1))[2] = 255;
                    }
                    else if (xR < 0)
                    {
                        (dataPtrDestino + widthStep * (height - 1))[2] = 0;
                    }
                    else
                    {
                        (dataPtrDestino + widthStep * (height - 1))[2] = (byte)xR;
                    }

                    //Canto Inferior Direito
                    xB = Math.Round(((((dataPtrCopia + widthStep * (height - 1) + nChan * (width - 1))[0] * (matrix[1, 1] + matrix[1, 2] + matrix[2, 1] + matrix[2, 2]))) + (((dataPtrCopia + nChan * (width - 1) + widthStep * (height - 2))[0] * (matrix[0, 1] + matrix[0, 2]))) + (((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 1))[0] * (matrix[1, 0] + matrix[2, 0]))) + (dataPtrCopia + nChan * (width - 2) + widthStep * (height - 2))[0] * matrix[0, 0]) / matrixWeight);
                    xG = Math.Round(((((dataPtrCopia + widthStep * (height - 1) + nChan * (width - 1))[1] * (matrix[1, 1] + matrix[1, 2] + matrix[2, 1] + matrix[2, 2]))) + (((dataPtrCopia + nChan * (width - 1) + widthStep * (height - 2))[1] * (matrix[0, 1] + matrix[0, 2]))) + (((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 1))[1] * (matrix[1, 0] + matrix[2, 0]))) + (dataPtrCopia + nChan * (width - 2) + widthStep * (height - 2))[1] * matrix[0, 0]) / matrixWeight);
                    xR = Math.Round(((((dataPtrCopia + widthStep * (height - 1) + nChan * (width - 1))[2] * (matrix[1, 1] + matrix[1, 2] + matrix[2, 1] + matrix[2, 2]))) + (((dataPtrCopia + nChan * (width - 1) + widthStep * (height - 2))[2] * (matrix[0, 1] + matrix[0, 2]))) + (((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 1))[2] * (matrix[1, 0] + matrix[2, 0]))) + (dataPtrCopia + nChan * (width - 2) + widthStep * (height - 2))[2] * matrix[0, 0]) / matrixWeight);

                    if (xB > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[0] = 255;
                    }
                    else if (xB < 0)
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[0] = 0;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[0] = (byte)xB;
                    }

                    if (xG > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[1] = 255;
                    }
                    else if (xG < 0)
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[1] = 0;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[1] = (byte)xG;
                    }

                    if (xR > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[2] = 255;
                    }
                    else if (xR < 0)
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[2] = 0;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[2] = (byte)xR;
                    }

                    //Laterais Horizontais
                    for (x = 1; x <= width - 2; x++)
                    {
                        //Lateral Cima
                        xB = Math.Round((((((dataPtrCopia + nChan * x)[0] * (matrix[0, 1] + matrix[1, 1])) + ((dataPtrCopia + nChan * (x + 1))[0] * (matrix[0, 2] + matrix[1, 2])) + ((dataPtrCopia + nChan * (x - 1))[0] * (matrix[0, 0] + matrix[1, 0])))) + ((dataPtrCopia + nChan * x + widthStep)[0] * matrix[2, 1]) + ((dataPtrCopia + nChan * (x + 1) + widthStep)[0] * matrix[2, 2]) + ((dataPtrCopia + nChan * (x - 1) + widthStep)[0] * matrix[2, 0])) / matrixWeight);
                        xG = Math.Round((((((dataPtrCopia + nChan * x)[1] * (matrix[0, 1] + matrix[1, 1])) + ((dataPtrCopia + nChan * (x + 1))[1] * (matrix[0, 2] + matrix[1, 2])) + ((dataPtrCopia + nChan * (x - 1))[1] * (matrix[0, 0] + matrix[1, 0])))) + ((dataPtrCopia + nChan * x + widthStep)[1] * matrix[2, 1]) + ((dataPtrCopia + nChan * (x + 1) + widthStep)[1] * matrix[2, 2]) + ((dataPtrCopia + nChan * (x - 1) + widthStep)[1] * matrix[2, 0])) / matrixWeight);
                        xR = Math.Round((((((dataPtrCopia + nChan * x)[2] * (matrix[0, 1] + matrix[1, 1])) + ((dataPtrCopia + nChan * (x + 1))[2] * (matrix[0, 2] + matrix[1, 2])) + ((dataPtrCopia + nChan * (x - 1))[2] * (matrix[0, 0] + matrix[1, 0])))) + ((dataPtrCopia + nChan * x + widthStep)[2] * matrix[2, 1]) + ((dataPtrCopia + nChan * (x + 1) + widthStep)[2] * matrix[2, 2]) + ((dataPtrCopia + nChan * (x - 1) + widthStep)[2] * matrix[2, 0])) / matrixWeight);

                        if (xB > 255)
                        {
                            (dataPtrDestino + nChan * x)[0] = 255;
                        }
                        else if (xB < 0)
                        {
                            (dataPtrDestino + nChan * x)[0] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x)[0] = (byte)xB;
                        }

                        if (xG > 255)
                        {
                            (dataPtrDestino + nChan * x)[1] = 255;
                        }
                        else if (xG < 0)
                        {
                            (dataPtrDestino + nChan * x)[1] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x)[1] = (byte)xG;
                        }

                        if (xR > 255)
                        {
                            (dataPtrDestino + nChan * x)[2] = 255;
                        }
                        else if (xR < 0)
                        {
                            (dataPtrDestino + nChan * x)[2] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x)[2] = (byte)xR;
                        }

                        //Lateral Baixo
                        xB = Math.Round((((dataPtrCopia + nChan * x + widthStep * (height - 1))[0] * (matrix[1, 1] + matrix[2, 1])) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (height - 1))[0] * (matrix[1, 2] + matrix[2, 2])) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 1))[0] * (matrix[1, 0] + matrix[2, 0])) + ((dataPtrCopia + nChan * x + widthStep * (height - 2))[0] * matrix[0, 1]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (height - 2))[0] * matrix[0, 2]) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 2))[0] * matrix[0, 0])) / matrixWeight);
                        xG = Math.Round((((dataPtrCopia + nChan * x + widthStep * (height - 1))[1] * (matrix[1, 1] + matrix[2, 1])) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (height - 1))[1] * (matrix[1, 2] + matrix[2, 2])) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 1))[1] * (matrix[1, 0] + matrix[2, 0])) + ((dataPtrCopia + nChan * x + widthStep * (height - 2))[1] * matrix[0, 1]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (height - 2))[1] * matrix[0, 2]) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 2))[1] * matrix[0, 0])) / matrixWeight);
                        xR = Math.Round((((dataPtrCopia + nChan * x + widthStep * (height - 1))[2] * (matrix[1, 1] + matrix[2, 1])) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (height - 1))[2] * (matrix[1, 2] + matrix[2, 2])) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 1))[2] * (matrix[1, 0] + matrix[2, 0])) + ((dataPtrCopia + nChan * x + widthStep * (height - 2))[2] * matrix[0, 1]) + ((dataPtrCopia + nChan * (x + 1) + widthStep * (height - 2))[2] * matrix[0, 2]) + ((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 2))[2] * matrix[0, 0])) / matrixWeight);

                        if (xB > 255)
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[0] = 255;
                        }
                        else if (xB < 0)
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[0] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[0] = (byte)xB;
                        }

                        if (xG > 255)
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[1] = 255;
                        }
                        else if (xG < 0)
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[1] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[1] = (byte)xG;
                        }

                        if (xR > 255)
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[2] = 255;
                        }
                        else if (xR < 0)
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[2] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[2] = (byte)xR;
                        }

                    }

                    //Laterais Verticais
                    for (y = 1; y <= height - 2; y++)
                    {

                        //Lateral Esquerda
                        xB = Math.Round((((dataPtrCopia + widthStep * y)[0] * (matrix[0, 1] + matrix[1, 1])) + ((dataPtrCopia + widthStep * (y - 1))[0] * (matrix[0, 0] + matrix[0, 1])) + ((dataPtrCopia + widthStep * (y + 1))[0] * (matrix[2, 0] + matrix[2, 1])) + ((dataPtrCopia + nChan + widthStep * y)[0] * matrix[1, 2]) + ((dataPtrCopia + nChan + widthStep * (y + 1))[0] * matrix[2, 2]) + ((dataPtrCopia + nChan + widthStep * (y - 1))[0] * matrix[0, 2])) / matrixWeight);
                        xG = Math.Round((((dataPtrCopia + widthStep * y)[1] * (matrix[0, 1] + matrix[1, 1])) + ((dataPtrCopia + widthStep * (y - 1))[1] * (matrix[0, 0] + matrix[0, 1])) + ((dataPtrCopia + widthStep * (y + 1))[1] * (matrix[2, 0] + matrix[2, 1])) + ((dataPtrCopia + nChan + widthStep * y)[1] * matrix[1, 2]) + ((dataPtrCopia + nChan + widthStep * (y + 1))[1] * matrix[2, 2]) + ((dataPtrCopia + nChan + widthStep * (y - 1))[1] * matrix[0, 2])) / matrixWeight);
                        xR = Math.Round((((dataPtrCopia + widthStep * y)[2] * (matrix[0, 1] + matrix[1, 1])) + ((dataPtrCopia + widthStep * (y - 1))[2] * (matrix[0, 0] + matrix[0, 1])) + ((dataPtrCopia + widthStep * (y + 1))[2] * (matrix[2, 0] + matrix[2, 1])) + ((dataPtrCopia + nChan + widthStep * y)[2] * matrix[1, 2]) + ((dataPtrCopia + nChan + widthStep * (y + 1))[2] * matrix[2, 2]) + ((dataPtrCopia + nChan + widthStep * (y - 1))[2] * matrix[0, 2])) / matrixWeight);

                        if (xB > 255)
                        {
                            (dataPtrDestino + widthStep * y)[0] = 255;
                        }
                        else if (xB < 0)
                        {
                            (dataPtrDestino + widthStep * y)[0] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + widthStep * y)[0] = (byte)xB;
                        }

                        if (xG > 255)
                        {
                            (dataPtrDestino + widthStep * y)[1] = 255;
                        }
                        else if (xG < 0)
                        {
                            (dataPtrDestino + widthStep * y)[1] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + widthStep * y)[1] = (byte)xG;
                        }

                        if (xR > 255)
                        {
                            (dataPtrDestino + widthStep * y)[2] = 255;
                        }
                        else if (xR < 0)
                        {
                            (dataPtrDestino + widthStep * y)[2] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + widthStep * y)[2] = (byte)xR;
                        }

                        //Lateral Direita
                        xB = Math.Round((((dataPtrCopia + nChan * (width - 1) + widthStep * y)[0] * (matrix[1, 1] + matrix[1, 2])) + ((dataPtrCopia + nChan * (width - 1) + widthStep * (y + 1))[0] * (matrix[2, 1] + matrix[2, 2])) + ((dataPtrCopia + nChan * (width - 1) + widthStep * (y - 1))[0] * (matrix[0, 1] + matrix[0, 2])) + ((dataPtrCopia + nChan * (width - 2) + widthStep * y)[0] * matrix[1, 0]) + ((dataPtrCopia + nChan * (width - 2) + widthStep * (y + 1))[0] * matrix[2, 0]) + ((dataPtrCopia + nChan * (width - 2) + widthStep * (y - 1))[0] * matrix[0, 0])) / matrixWeight);
                        xG = Math.Round((((dataPtrCopia + nChan * (width - 1) + widthStep * y)[1] * (matrix[1, 1] + matrix[1, 2])) + ((dataPtrCopia + nChan * (width - 1) + widthStep * (y + 1))[1] * (matrix[2, 1] + matrix[2, 2])) + ((dataPtrCopia + nChan * (width - 1) + widthStep * (y - 1))[1] * (matrix[0, 1] + matrix[0, 2])) + ((dataPtrCopia + nChan * (width - 2) + widthStep * y)[1] * matrix[1, 0]) + ((dataPtrCopia + nChan * (width - 2) + widthStep * (y + 1))[1] * matrix[2, 0]) + ((dataPtrCopia + nChan * (width - 2) + widthStep * (y - 1))[1] * matrix[0, 0])) / matrixWeight);
                        xR = Math.Round((((dataPtrCopia + nChan * (width - 1) + widthStep * y)[2] * (matrix[1, 1] + matrix[1, 2])) + ((dataPtrCopia + nChan * (width - 1) + widthStep * (y + 1))[2] * (matrix[2, 1] + matrix[2, 2])) + ((dataPtrCopia + nChan * (width - 1) + widthStep * (y - 1))[2] * (matrix[0, 1] + matrix[0, 2])) + ((dataPtrCopia + nChan * (width - 2) + widthStep * y)[2] * matrix[1, 0]) + ((dataPtrCopia + nChan * (width - 2) + widthStep * (y + 1))[2] * matrix[2, 0]) + ((dataPtrCopia + nChan * (width - 2) + widthStep * (y - 1))[2] * matrix[0, 0])) / matrixWeight);

                        if (xB > 255)
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[0] = 255;
                        }
                        else if (xB < 0)
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[0] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[0] = (byte)xB;
                        }

                        if (xG > 255)
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[1] = 255;
                        }
                        else if (xG < 0)
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[1] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[1] = (byte)xG;
                        }

                        if (xR > 255)
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[2] = 255;
                        }
                        else if (xR < 0)
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[2] = 0;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[2] = (byte)xR;
                        }
                    }
                }
            }
        }

        public static void Sobel(Image<Bgr, byte> img, Image<Bgr, byte> imgCopy)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                MIplImage copia = imgCopy.MIplImage;

                byte* dataPtrDestino = (byte*)m.imageData.ToPointer();
                byte* dataPtrCopia = (byte*)copia.imageData.ToPointer();
                int width = img.Width;
                int height = img.Height;
                int nChan = m.nChannels;
                int widthStep = m.widthStep;
                int x, y, sxR, sxB, sxG, syR, syB, syG;


                if (nChan == 3)
                {
                    //centro da imagem
                    for (x = 1; x < width - 1; x++)
                    {
                        for (y = 1; y < height - 1; y++)
                        {
                            // Sx = (a + 2d +g) - (c + 2f + i)
                            sxB = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (y - 1))[0] + (2 * (dataPtrCopia + nChan * (x - 1) + widthStep * y)[0]) + (dataPtrCopia + nChan * (x - 1) + widthStep * (y + 1))[0]) - ((dataPtrCopia + nChan * (x + 1) + widthStep * (y - 1))[0] + (2 * (dataPtrCopia + nChan * (x + 1) + widthStep * y)[0]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (y + 1))[0]));
                            sxG = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (y - 1))[1] + (2 * (dataPtrCopia + nChan * (x - 1) + widthStep * y)[1]) + (dataPtrCopia + nChan * (x - 1) + widthStep * (y + 1))[1]) - ((dataPtrCopia + nChan * (x + 1) + widthStep * (y - 1))[1] + (2 * (dataPtrCopia + nChan * (x + 1) + widthStep * y)[1]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (y + 1))[1]));
                            sxR = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (y - 1))[2] + (2 * (dataPtrCopia + nChan * (x - 1) + widthStep * y)[2]) + (dataPtrCopia + nChan * (x - 1) + widthStep * (y + 1))[2]) - ((dataPtrCopia + nChan * (x + 1) + widthStep * (y - 1))[2] + (2 * (dataPtrCopia + nChan * (x + 1) + widthStep * y)[2]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (y + 1))[2]));

                            // Sy = (g + 2h + i) - a + 2b + c)
                            syB = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (y + 1))[0] + (2 * (dataPtrCopia + nChan * x + widthStep * (y + 1))[0]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (y + 1))[0]) - ((dataPtrCopia + nChan * (x - 1) + widthStep * (y - 1))[0] + (2 * (dataPtrCopia + nChan * x + widthStep * (y - 1))[0]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (y - 1))[0]));
                            syG = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (y + 1))[1] + (2 * (dataPtrCopia + nChan * x + widthStep * (y + 1))[1]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (y + 1))[1]) - ((dataPtrCopia + nChan * (x - 1) + widthStep * (y - 1))[1] + (2 * (dataPtrCopia + nChan * x + widthStep * (y - 1))[1]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (y - 1))[1]));
                            syR = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (y + 1))[2] + (2 * (dataPtrCopia + nChan * x + widthStep * (y + 1))[2]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (y + 1))[2]) - ((dataPtrCopia + nChan * (x - 1) + widthStep * (y - 1))[2] + (2 * (dataPtrCopia + nChan * x + widthStep * (y - 1))[2]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (y - 1))[2]));

                            // ValorDestino = |Sx| + |Sy|
                            if (sxB + syB > 255)
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[0] = 255;
                            }
                            else
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[0] = (byte)(sxB + syB);
                            }
                            if (sxG + syG > 255)
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[1] = 255;
                            }
                            else
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[1] = (byte)(sxG + syG);
                            }
                            if (sxR + syR > 255)
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[2] = 255;
                            }
                            else
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[2] = (byte)(sxR + syR);
                            }
                        }
                    }

                    //cantos

                    //Canto superior esquerdo (0,0)
                    sxB = Math.Abs(((3 * (dataPtrCopia)[0] + (dataPtrCopia + widthStep)[0])) - ((3 * (dataPtrCopia + nChan)[0]) + (dataPtrCopia + nChan + widthStep)[0]));
                    sxG = Math.Abs(((3 * (dataPtrCopia)[1] + (dataPtrCopia + widthStep)[1])) - ((3 * (dataPtrCopia + nChan)[1]) + (dataPtrCopia + nChan + widthStep)[1]));
                    sxR = Math.Abs(((3 * (dataPtrCopia)[2] + (dataPtrCopia + widthStep)[2])) - ((3 * (dataPtrCopia + nChan)[2]) + (dataPtrCopia + nChan + widthStep)[2]));

                    syB = Math.Abs(((3 * (dataPtrCopia + widthStep)[0]) + (dataPtrCopia + nChan + widthStep)[0]) - ((3 * (dataPtrCopia)[0]) + (dataPtrCopia + nChan)[0]));
                    syG = Math.Abs(((3 * (dataPtrCopia + widthStep)[1]) + (dataPtrCopia + nChan + widthStep)[1]) - ((3 * (dataPtrCopia)[1]) + (dataPtrCopia + nChan)[1]));
                    syR = Math.Abs(((3 * (dataPtrCopia + widthStep)[2]) + (dataPtrCopia + nChan + widthStep)[2]) - ((3 * (dataPtrCopia)[2]) + (dataPtrCopia + nChan)[2]));

                    if (sxB + syB > 255)
                    {
                        (dataPtrDestino)[0] = 255;
                    }
                    else
                    {
                        (dataPtrDestino)[0] = (byte)(sxB + syB);
                    }
                    if (sxG + syG > 255)
                    {
                        (dataPtrDestino)[1] = 255;
                    }
                    else
                    {
                        (dataPtrDestino)[1] = (byte)(sxG + syG);
                    }
                    if (sxR + syR > 255)
                    {
                        (dataPtrDestino)[2] = 255;
                    }
                    else
                    {
                        (dataPtrDestino)[2] = (byte)(sxR + syR);
                    }


                    //Canto Superior Direito (width - 1, 0)
                    sxB = Math.Abs(((3 * (dataPtrCopia + nChan * (width - 2))[0]) + (dataPtrCopia + nChan * (width - 2) + widthStep)[0]) - ((3 * (dataPtrCopia + nChan * (width - 1))[0]) + (dataPtrCopia + widthStep + nChan * (width - 1))[0]));
                    sxG = Math.Abs(((3 * (dataPtrCopia + nChan * (width - 2))[1]) + (dataPtrCopia + nChan * (width - 2) + widthStep)[1]) - ((3 * (dataPtrCopia + nChan * (width - 1))[1]) + (dataPtrCopia + widthStep + nChan * (width - 1))[1]));
                    sxR = Math.Abs(((3 * (dataPtrCopia + nChan * (width - 2))[2]) + (dataPtrCopia + nChan * (width - 2) + widthStep)[2]) - ((3 * (dataPtrCopia + nChan * (width - 1))[2]) + (dataPtrCopia + widthStep + nChan * (width - 1))[2]));

                    syB = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep)[0] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep)[0])) - ((dataPtrCopia + nChan * (width - 2))[0] + (3 * (dataPtrCopia + nChan * (width - 1))[0])));
                    syG = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep)[1] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep)[1])) - ((dataPtrCopia + nChan * (width - 2))[1] + (3 * (dataPtrCopia + nChan * (width - 1))[1])));
                    syR = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep)[2] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep)[2])) - ((dataPtrCopia + nChan * (width - 2))[2] + (3 * (dataPtrCopia + nChan * (width - 1))[2])));


                    if (sxB + syB > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1))[0] = 255;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1))[0] = (byte)(sxB + syB);
                    }
                    if (sxG + syG > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1))[1] = 255;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1))[1] = (byte)(sxG + syG);
                    }
                    if (sxR + syR > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1))[2] = 255;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1))[2] = (byte)(sxR + syR);
                    }

                    //Canto Inferior Esquerdo (0, height - 1)
                    sxB = Math.Abs(((dataPtrCopia + widthStep * (height - 2))[0] + (3 * (dataPtrCopia + widthStep * (height - 1))[0])) - ((dataPtrCopia + nChan + widthStep * (height - 2))[0] + (3 * (dataPtrCopia + nChan + widthStep * (height - 1))[0])));
                    sxG = Math.Abs(((dataPtrCopia + widthStep * (height - 2))[1] + (3 * (dataPtrCopia + widthStep * (height - 1))[1])) - ((dataPtrCopia + nChan + widthStep * (height - 2))[1] + (3 * (dataPtrCopia + nChan + widthStep * (height - 1))[1])));
                    sxR = Math.Abs(((dataPtrCopia + widthStep * (height - 2))[2] + (3 * (dataPtrCopia + widthStep * (height - 1))[2])) - ((dataPtrCopia + nChan + widthStep * (height - 2))[2] + (3 * (dataPtrCopia + nChan + widthStep * (height - 1))[2])));

                    syB = Math.Abs(((3 * (dataPtrCopia + widthStep * (height - 1))[0]) + (dataPtrCopia + nChan + widthStep * (height - 1))[0]) - ((3 * (dataPtrCopia + widthStep * (height - 2))[0]) + (dataPtrCopia + nChan + widthStep * (height - 2))[0]));
                    syG = Math.Abs(((3 * (dataPtrCopia + widthStep * (height - 1))[1]) + (dataPtrCopia + nChan + widthStep * (height - 1))[1]) - ((3 * (dataPtrCopia + widthStep * (height - 2))[1]) + (dataPtrCopia + nChan + widthStep * (height - 2))[1]));
                    syR = Math.Abs(((3 * (dataPtrCopia + widthStep * (height - 1))[2]) + (dataPtrCopia + nChan + widthStep * (height - 1))[2]) - ((3 * (dataPtrCopia + widthStep * (height - 2))[2]) + (dataPtrCopia + nChan + widthStep * (height - 2))[2]));


                    if (sxB + syB > 255)
                    {
                        (dataPtrDestino + widthStep * (height - 1))[0] = 255;
                    }
                    else
                    {
                        (dataPtrDestino + widthStep * (height - 1))[0] = (byte)(sxB + syB);
                    }
                    if (sxG + syG > 255)
                    {
                        (dataPtrDestino + widthStep * (height - 1))[1] = 255;
                    }
                    else
                    {
                        (dataPtrDestino + widthStep * (height - 1))[1] = (byte)(sxG + syG);
                    }
                    if (sxR + syR > 255)
                    {
                        (dataPtrDestino + widthStep * (height - 1))[2] = 255;
                    }
                    else
                    {
                        (dataPtrDestino + widthStep * (height - 1))[2] = (byte)(sxR + syR);
                    }


                    //Canto Inferior Direito (width - 1, height - 1)
                    sxB = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 2))[0] + (3 * (dataPtrCopia + nChan * (width - 2) + widthStep * (height - 1))[0])) - ((dataPtrCopia + nChan * (width - 1) + widthStep * (height - 2))[0] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (height - 1))[0])));
                    sxG = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 2))[1] + (3 * (dataPtrCopia + nChan * (width - 2) + widthStep * (height - 1))[1])) - ((dataPtrCopia + nChan * (width - 1) + widthStep * (height - 2))[1] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (height - 1))[1])));
                    sxR = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 2))[2] + (3 * (dataPtrCopia + nChan * (width - 2) + widthStep * (height - 1))[2])) - ((dataPtrCopia + nChan * (width - 1) + widthStep * (height - 2))[2] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (height - 1))[2])));

                    syB = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 1))[0] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (height - 1))[0])) - ((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 2))[0] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (height - 2))[0])));
                    syG = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 1))[1] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (height - 1))[1])) - ((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 2))[1] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (height - 2))[1])));
                    syR = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 1))[2] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (height - 1))[2])) - ((dataPtrCopia + nChan * (width - 2) + widthStep * (height - 2))[2] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (height - 2))[2])));

                    if (sxB + syB > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[0] = 255;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[0] = (byte)(sxB + syB);
                    }
                    if (sxG + syG > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[1] = 255;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[1] = (byte)(sxG + syG);
                    }
                    if (sxR + syR > 255)
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[2] = 255;
                    }
                    else
                    {
                        (dataPtrDestino + nChan * (width - 1) + widthStep * (height - 1))[2] = (byte)(sxR + syR);
                    }

                    //Laterais Horizontais
                    for (x = 1; x < width - 1; x++)
                    {

                        //Horizontal de cima
                        sxB = Math.Abs(((3 * (dataPtrCopia + nChan * (x - 1))[0]) + (dataPtrCopia + nChan * (x - 1) + widthStep)[0]) - ((3 * (dataPtrCopia + nChan * (x + 1))[0]) + (dataPtrCopia + nChan * (x + 1) + widthStep)[0]));
                        sxG = Math.Abs(((3 * (dataPtrCopia + nChan * (x - 1))[1]) + (dataPtrCopia + nChan * (x - 1) + widthStep)[1]) - ((3 * (dataPtrCopia + nChan * (x + 1))[1]) + (dataPtrCopia + nChan * (x + 1) + widthStep)[1]));
                        sxR = Math.Abs(((3 * (dataPtrCopia + nChan * (x - 1))[2]) + (dataPtrCopia + nChan * (x - 1) + widthStep)[2]) - ((3 * (dataPtrCopia + nChan * (x + 1))[2]) + (dataPtrCopia + nChan * (x + 1) + widthStep)[2]));

                        syB = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep)[0] + (2 * (dataPtrCopia + nChan * x + widthStep)[0]) + (dataPtrCopia + nChan * (x + 1) + widthStep)[0]) - ((dataPtrCopia + nChan * (x - 1))[0] + (2 * (dataPtrCopia + nChan * x)[0]) + (dataPtrCopia + nChan * (x + 1))[0]));
                        syG = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep)[1] + (2 * (dataPtrCopia + nChan * x + widthStep)[1]) + (dataPtrCopia + nChan * (x + 1) + widthStep)[1]) - ((dataPtrCopia + nChan * (x - 1))[1] + (2 * (dataPtrCopia + nChan * x)[1]) + (dataPtrCopia + nChan * (x + 1))[1]));
                        syR = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep)[2] + (2 * (dataPtrCopia + nChan * x + widthStep)[2]) + (dataPtrCopia + nChan * (x + 1) + widthStep)[2]) - ((dataPtrCopia + nChan * (x - 1))[2] + (2 * (dataPtrCopia + nChan * x)[2]) + (dataPtrCopia + nChan * (x + 1))[2]));

                        if (sxB + syB > 255)
                        {
                            (dataPtrDestino + nChan * x)[0] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x)[0] = (byte)(sxB + syB);
                        }
                        if (sxG + syG > 255)
                        {
                            (dataPtrDestino + nChan * x)[1] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x)[1] = (byte)(sxG + syG);
                        }
                        if (sxR + syR > 255)
                        {
                            (dataPtrDestino + nChan * x)[2] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x)[2] = (byte)(sxR + syR);
                        }


                        //Horizontal de baixo
                        sxB = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 2))[0] + (3 * (dataPtrCopia + nChan * (x - 1) + widthStep * (height - 1))[0])) - ((dataPtrCopia + nChan * (x + 1) + widthStep * (height - 2))[0] + (3 * (dataPtrCopia + nChan * (x + 1) + widthStep * (height - 1))[0])));
                        sxG = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 2))[1] + (3 * (dataPtrCopia + nChan * (x - 1) + widthStep * (height - 1))[1])) - ((dataPtrCopia + nChan * (x + 1) + widthStep * (height - 2))[1] + (3 * (dataPtrCopia + nChan * (x + 1) + widthStep * (height - 1))[1])));
                        sxR = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 2))[2] + (3 * (dataPtrCopia + nChan * (x - 1) + widthStep * (height - 1))[2])) - ((dataPtrCopia + nChan * (x + 1) + widthStep * (height - 2))[2] + (3 * (dataPtrCopia + nChan * (x + 1) + widthStep * (height - 1))[2])));

                        syB = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 1))[0] + (2 * (dataPtrCopia + nChan * x + widthStep * (height - 1))[0]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (height - 1))[0]) - ((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 2))[0] + (2 * (dataPtrCopia + nChan * x + widthStep * (height - 2))[0]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (height - 2))[0]));
                        syG = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 1))[1] + (2 * (dataPtrCopia + nChan * x + widthStep * (height - 1))[1]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (height - 1))[1]) - ((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 2))[1] + (2 * (dataPtrCopia + nChan * x + widthStep * (height - 2))[1]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (height - 2))[1]));
                        syR = Math.Abs(((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 1))[2] + (2 * (dataPtrCopia + nChan * x + widthStep * (height - 1))[2]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (height - 1))[2]) - ((dataPtrCopia + nChan * (x - 1) + widthStep * (height - 2))[2] + (2 * (dataPtrCopia + nChan * x + widthStep * (height - 2))[2]) + (dataPtrCopia + nChan * (x + 1) + widthStep * (height - 2))[2]));

                        if (sxB + syB > 255)
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[0] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[0] = (byte)(sxB + syB);
                        }
                        if (sxG + syG > 255)
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[1] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[1] = (byte)(sxG + syG);
                        }
                        if (sxR + syR > 255)
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[2] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * x + widthStep * (height - 1))[2] = (byte)(sxR + syR);
                        }
                    }

                    //Laterais
                    for (y = 1; y < height - 1; y++)
                    {

                        //Lateral Esquerda
                        sxB = Math.Abs(((dataPtrCopia + widthStep * (y - 1))[0] + (2 * (dataPtrCopia + widthStep * y)[0]) + (dataPtrCopia + widthStep * (y + 1))[0]) - ((dataPtrCopia + nChan + widthStep * (y - 1))[0] + (2 * (dataPtrCopia + nChan + widthStep * y)[0]) + (dataPtrCopia + nChan + widthStep * (y + 1))[0]));
                        sxG = Math.Abs(((dataPtrCopia + widthStep * (y - 1))[1] + (2 * (dataPtrCopia + widthStep * y)[1]) + (dataPtrCopia + widthStep * (y + 1))[1]) - ((dataPtrCopia + nChan + widthStep * (y - 1))[1] + (2 * (dataPtrCopia + nChan + widthStep * y)[1]) + (dataPtrCopia + nChan + widthStep * (y + 1))[1]));
                        sxR = Math.Abs(((dataPtrCopia + widthStep * (y - 1))[2] + (2 * (dataPtrCopia + widthStep * y)[2]) + (dataPtrCopia + widthStep * (y + 1))[2]) - ((dataPtrCopia + nChan + widthStep * (y - 1))[2] + (2 * (dataPtrCopia + nChan + widthStep * y)[2]) + (dataPtrCopia + nChan + widthStep * (y + 1))[2]));

                        syB = Math.Abs(((3 * (dataPtrCopia + widthStep * (y + 1))[0]) + (dataPtrCopia + nChan + widthStep * (y + 1))[0]) - ((3 * (dataPtrCopia + widthStep * (y - 1))[0]) + (dataPtrCopia + nChan + widthStep * (y - 1))[0]));
                        syG = Math.Abs(((3 * (dataPtrCopia + widthStep * (y + 1))[1]) + (dataPtrCopia + nChan + widthStep * (y + 1))[1]) - ((3 * (dataPtrCopia + widthStep * (y - 1))[1]) + (dataPtrCopia + nChan + widthStep * (y - 1))[1]));
                        syR = Math.Abs(((3 * (dataPtrCopia + widthStep * (y + 1))[2]) + (dataPtrCopia + nChan + widthStep * (y + 1))[2]) - ((3 * (dataPtrCopia + widthStep * (y - 1))[2]) + (dataPtrCopia + nChan + widthStep * (y - 1))[2]));

                        if (sxB + syB > 255)
                        {
                            (dataPtrDestino + widthStep * y)[0] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + widthStep * y)[0] = (byte)(sxB + syB);
                        }
                        if (sxG + syG > 255)
                        {
                            (dataPtrDestino + widthStep * y)[1] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + widthStep * y)[1] = (byte)(sxG + syG);
                        }
                        if (sxR + syR > 255)
                        {
                            (dataPtrDestino + widthStep * y)[2] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + widthStep * y)[2] = (byte)(sxR + syR);
                        }


                        //Lateral Direita
                        sxB = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (y - 1))[0] + (2 * (dataPtrCopia + nChan * (width - 2) + widthStep * y)[0]) + (dataPtrCopia + nChan * (width - 2) + widthStep * (y + 1))[0]) - ((dataPtrCopia + nChan * (width - 1) + widthStep * (y - 1))[0] + (2 * (dataPtrCopia + nChan * (width - 1) + widthStep * y)[0]) + (dataPtrCopia + nChan * (width - 1) + widthStep * (y + 1))[0]));
                        sxG = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (y - 1))[1] + (2 * (dataPtrCopia + nChan * (width - 2) + widthStep * y)[1]) + (dataPtrCopia + nChan * (width - 2) + widthStep * (y + 1))[1]) - ((dataPtrCopia + nChan * (width - 1) + widthStep * (y - 1))[1] + (2 * (dataPtrCopia + nChan * (width - 1) + widthStep * y)[1]) + (dataPtrCopia + nChan * (width - 1) + widthStep * (y + 1))[1]));
                        sxR = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (y - 1))[2] + (2 * (dataPtrCopia + nChan * (width - 2) + widthStep * y)[2]) + (dataPtrCopia + nChan * (width - 2) + widthStep * (y + 1))[2]) - ((dataPtrCopia + nChan * (width - 1) + widthStep * (y - 1))[2] + (2 * (dataPtrCopia + nChan * (width - 1) + widthStep * y)[2]) + (dataPtrCopia + nChan * (width - 1) + widthStep * (y + 1))[2]));

                        syB = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (y + 1))[0] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (y + 1))[0])) - ((dataPtrCopia + nChan * (width - 2) + widthStep * (y - 1))[0] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (y - 1))[0])));
                        syG = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (y + 1))[1] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (y + 1))[1])) - ((dataPtrCopia + nChan * (width - 2) + widthStep * (y - 1))[1] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (y - 1))[1])));
                        syR = Math.Abs(((dataPtrCopia + nChan * (width - 2) + widthStep * (y + 1))[2] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (y + 1))[2])) - ((dataPtrCopia + nChan * (width - 2) + widthStep * (y - 1))[2] + (3 * (dataPtrCopia + nChan * (width - 1) + widthStep * (y - 1))[2])));

                        if (sxB + syB > 255)
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[0] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[0] = (byte)(sxB + syB);
                        }
                        if (sxG + syG > 255)
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[1] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[1] = (byte)(sxG + syG);
                        }
                        if (sxR + syR > 255)
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[2] = 255;
                        }
                        else
                        {
                            (dataPtrDestino + nChan * (width - 1) + widthStep * y)[2] = (byte)(sxR + syR);
                        }
                    }
                }
            }
        }

        public static void Diferentiation(Image<Bgr, byte> img, Image<Bgr, byte> imgCopy)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                MIplImage mUndo = imgCopy.MIplImage;

                byte* dataPtrCopy = (byte*)mUndo.imageData.ToPointer();
                byte* dataPtr = (byte*)m.imageData.ToPointer();
                int blue, green, red;
                int width = imgCopy.Width;
                int height = imgCopy.Height;
                int nChan = mUndo.nChannels;
                int widthStep = mUndo.widthStep;
                int padding = mUndo.widthStep - mUndo.nChannels * mUndo.width;

                if (nChan == 3)
                {
                    for (int y = 0; y < height - 1; y++)
                    {
                        for (int x = 0; x < width - 1; x++)
                        {
                            blue = (int)(Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[0] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[0]) + Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[0]));
                            if (blue > 255)
                            {
                                blue = 255;
                            }
                            (dataPtr + y * widthStep + x * nChan)[0] = (byte)blue;

                            green = (int)(Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[1] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[1]) + Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[1]));
                            if (green > 255)
                            {
                                green = 255;
                            }
                            (dataPtr + y * widthStep + x * nChan)[1] = (byte)green;

                            red = (int)(Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[2] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[2]) + Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[2]));
                            if (red > 255)
                            {
                                red = 255;
                            }
                            (dataPtr + y * widthStep + x * nChan)[2] = (byte)red;
                        }
                    }

                    //Border Right
                    for (int y = 0; y < height - 1; y++)
                    {
                        blue = (int)(Math.Abs((dataPtrCopy + y * widthStep + (width - 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (width - 1) * nChan)[0]));
                        if (blue > 255)
                        {
                            blue = 255;
                        }
                        (dataPtr + y * widthStep + (width - 1) * nChan)[0] = (byte)blue;

                        green = (int)(Math.Abs((dataPtrCopy + y * widthStep + (width - 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (width - 1) * nChan)[1]));
                        if (green > 255)
                        {
                            green = 255;
                        }
                        (dataPtr + y * widthStep + (width - 1) * nChan)[1] = (byte)green;


                        red = (int)(Math.Abs((dataPtrCopy + y * widthStep + (width - 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (width - 1) * nChan)[2]));
                        if (red > 255)
                        {
                            red = 255;
                        }
                        (dataPtr + y * widthStep + (width - 1) * nChan)[2] = (byte)red;
                    }


                    //Border Down
                    for (int x = 0; x < width - 1; x++)
                    {
                        blue = (int)(Math.Abs((dataPtrCopy + (height - 1) * widthStep + x * nChan)[0] - (dataPtrCopy + (height - 1) * widthStep + (x + 1) * nChan)[0]));
                        if (blue > 255)
                        {
                            (dataPtr + (height - 1) * widthStep + x * nChan)[0] = 255;
                        }
                        (dataPtr + (height - 1) * widthStep + x * nChan)[0] = (byte)blue;

                        green = (int)(Math.Abs((dataPtrCopy + (height - 1) * widthStep + x * nChan)[1] - (dataPtrCopy + (height - 1) * widthStep + (x + 1) * nChan)[1]));
                        if (green > 255)
                        {
                            (dataPtr + (height - 1) * widthStep + x * nChan)[1] = 255;
                        }
                        (dataPtr + (height - 1) * widthStep + x * nChan)[1] = (byte)green;

                        red = (int)(Math.Abs((dataPtrCopy + (height - 1) * widthStep + x * nChan)[2] - (dataPtrCopy + (height - 1) * widthStep + (x + 1) * nChan)[2]));
                        if (red > 255)
                        {
                            red = 255;
                        }
                        (dataPtr + (height - 1) * widthStep + x * nChan)[2] = (byte)red;

                    }
                    (dataPtr + (height - 1) * widthStep + (width - 1) * nChan)[0] = 0;
                    (dataPtr + (height - 1) * widthStep + (width - 1) * nChan)[1] = 0;
                    (dataPtr + (height - 1) * widthStep + (width - 1) * nChan)[2] = 0;

                }
            }
        }

        public static void Median(Image<Bgr, byte> img, Image<Bgr, byte> imgCopy)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                MIplImage mUndo = imgCopy.MIplImage;

                byte* dataPtrCopy = (byte*)mUndo.imageData.ToPointer();
                byte* dataPtr = (byte*)m.imageData.ToPointer();
                int width = imgCopy.Width;
                int height = imgCopy.Height;
                int nChan = mUndo.nChannels;
                int widthStep = mUndo.widthStep;
                int padding = mUndo.widthStep - mUndo.nChannels * mUndo.width;
                byte[] valorFinal = new byte[3];
                int valorMenor = 0;

                if (nChan == 3)
                {
                    int[] distancias = new int[9];
                    int x = 0;
                    int y = 0;
                    int count = 0;

                    for (y = 1; y < height - 1; y++)
                    {
                        for (x = 1; x < width - 1; x++)
                        {
                            distancias = new int[9];

                            distancias[0] =
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + y * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + y * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + y * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2]);

                            distancias[1] =
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[0] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[1] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[2] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[0] - (dataPtrCopy + y * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[1] - (dataPtrCopy + y * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[2] - (dataPtrCopy + y * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[0] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[1] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[2] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + x * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2]);

                            distancias[2] =
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + y * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + y * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + y * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2]);

                            distancias[3] =
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + y * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + y * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + y * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2]);

                            distancias[4] =
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + y * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + y * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + y * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2]);

                            distancias[5] =
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + y * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + y * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + y * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2]);

                            distancias[6] =
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[0] - (dataPtrCopy + y * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[1] - (dataPtrCopy + y * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[2] - (dataPtrCopy + y * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[0] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[1] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[2] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[0] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[1] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[2] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + x * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2]);

                            distancias[7] =
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + y * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + y * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + y * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[2]);

                            distancias[8] =
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[0] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[1] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[2] - (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[0] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[1] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[2] - (dataPtrCopy + y * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[0] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[1] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[2] - (dataPtrCopy + y * widthStep + (x + 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + x * nChan)[2]) +

                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[0] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[1] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1]) +
                                (int)Math.Abs((dataPtrCopy + y * widthStep + x * nChan)[2] - (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2]);

                            int minimo = distancias[0];
                            count = 0;
                            for (int j = 1; j < distancias.Length; j++)
                            {
                                if (distancias[j] < minimo)
                                {
                                    minimo = distancias[j];
                                    count = j;
                                }
                            }
                            switch (count)
                            {
                                case 0:
                                    (dataPtr + y * widthStep + x * nChan)[0] = (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[0];
                                    (dataPtr + y * widthStep + x * nChan)[1] = (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[1];
                                    (dataPtr + y * widthStep + x * nChan)[2] = (dataPtrCopy + (y - 1) * widthStep + (x - 1) * nChan)[2];
                                    break;
                                case 1:
                                    (dataPtr + y * widthStep + x * nChan)[0] = (dataPtrCopy + (y - 1) * widthStep + x * nChan)[0];
                                    (dataPtr + y * widthStep + x * nChan)[1] = (dataPtrCopy + (y - 1) * widthStep + x * nChan)[1];
                                    (dataPtr + y * widthStep + x * nChan)[2] = (dataPtrCopy + (y - 1) * widthStep + x * nChan)[2];
                                    break;
                                case 2:
                                    (dataPtr + y * widthStep + x * nChan)[0] = (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[0];
                                    (dataPtr + y * widthStep + x * nChan)[1] = (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[1];
                                    (dataPtr + y * widthStep + x * nChan)[2] = (dataPtrCopy + (y - 1) * widthStep + (x + 1) * nChan)[2];
                                    break;
                                case 3:
                                    (dataPtr + y * widthStep + x * nChan)[0] = (dataPtrCopy + y * widthStep + (x - 1) * nChan)[0];
                                    (dataPtr + y * widthStep + x * nChan)[1] = (dataPtrCopy + y * widthStep + (x - 1) * nChan)[1];
                                    (dataPtr + y * widthStep + x * nChan)[2] = (dataPtrCopy + y * widthStep + (x - 1) * nChan)[2];
                                    break;
                                case 4:
                                    (dataPtr + y * widthStep + x * nChan)[0] = (dataPtrCopy + y * widthStep + (x + 1) * nChan)[0];
                                    (dataPtr + y * widthStep + x * nChan)[1] = (dataPtrCopy + y * widthStep + (x + 1) * nChan)[1];
                                    (dataPtr + y * widthStep + x * nChan)[2] = (dataPtrCopy + y * widthStep + (x + 1) * nChan)[2];
                                    break;
                                case 5:
                                    (dataPtr + y * widthStep + x * nChan)[0] = (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[0];
                                    (dataPtr + y * widthStep + x * nChan)[1] = (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[1];
                                    (dataPtr + y * widthStep + x * nChan)[2] = (dataPtrCopy + (y + 1) * widthStep + (x - 1) * nChan)[2];
                                    break;
                                case 6:
                                    (dataPtr + y * widthStep + x * nChan)[0] = (dataPtrCopy + (y + 1) * widthStep + x * nChan)[0];
                                    (dataPtr + y * widthStep + x * nChan)[1] = (dataPtrCopy + (y + 1) * widthStep + x * nChan)[1];
                                    (dataPtr + y * widthStep + x * nChan)[2] = (dataPtrCopy + (y + 1) * widthStep + x * nChan)[2];
                                    break;
                                case 7:
                                    (dataPtr + y * widthStep + x * nChan)[0] = (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[0];
                                    (dataPtr + y * widthStep + x * nChan)[1] = (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[1];
                                    (dataPtr + y * widthStep + x * nChan)[2] = (dataPtrCopy + (y + 1) * widthStep + (x + 1) * nChan)[2];
                                    break;
                                case 8:
                                    break;

                            }


                        }
                    }


                    //margem de cima
                    for (x = 1; x < width - 1; x++)
                    {
                        y = 0;
                        distancias = new int[9];
                        count = 0;

                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                        distancias[3] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                        distancias[4] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                        distancias[5] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) + count +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) + count +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                        distancias[6] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                        distancias[7] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]);
                        distancias[8] = count;

                        valorMenor = distancias[3];
                        for (int a = 3; a < distancias.Length; a++)
                        {
                            if (distancias[a] < valorMenor)
                            {
                                valorMenor = distancias[a];
                                switch (a)
                                {
                                    case 3:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2];
                                        break;
                                    case 4:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y))[2];
                                        break;
                                    case 5:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2];
                                        break;
                                    case 6:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2];
                                        break;
                                    case 7:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2];
                                        break;
                                    case 8:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2];
                                        break;
                                }
                            }
                        }
                        (dataPtr + nChan * x + widthStep * y)[0] = valorFinal[0];
                        (dataPtr + nChan * x + widthStep * y)[1] = valorFinal[1];
                        (dataPtr + nChan * x + widthStep * y)[2] = valorFinal[2];
                    }


                    //margem de baixo

                    for (x = 1; x < width - 1; x++)
                    {
                        y = height - 1;
                        distancias = new int[9];
                        count = 0;

                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                        distancias[0] = count;

                        count = 0;
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                        distancias[1] = count;

                        count = 0;
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                        distancias[2] = count;

                        count = 0;
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                        distancias[3] = count;

                        count = 0;
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                        distancias[4] = count;

                        count = 0;
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                        distancias[5] = count;

                        valorMenor = distancias[0];
                        for (int a = 0; a < 6; a++)
                        {
                            if (distancias[a] < valorMenor)
                            {
                                valorMenor = distancias[a];
                                switch (a)
                                {
                                    case 0:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2];
                                        break;
                                    case 1:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2];
                                        break;
                                    case 2:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2];
                                        break;
                                    case 3:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2];
                                        break;
                                    case 4:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y))[2];
                                        break;
                                    case 5:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2];
                                        break;
                                }
                            }
                        }
                        (dataPtr + nChan * x + widthStep * y)[0] = valorFinal[0];
                        (dataPtr + nChan * x + widthStep * y)[1] = valorFinal[1];
                        (dataPtr + nChan * x + widthStep * y)[2] = valorFinal[2];
                    }


                    //margem da esquerda 
                    for (y = 1; y < height - 1; y++)
                    {
                        x = 0;
                        distancias = new int[9];
                        count = 0;

                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                        distancias[1] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                        distancias[2] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                        distancias[4] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                        distancias[5] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                        distancias[7] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                        distancias[8] = count;

                        valorMenor = distancias[1];
                        for (int a = 0; a < distancias.Length; a++)
                        {
                            if (distancias[a] < valorMenor && (a == 8 || a == 7 || a == 5 || a == 4 || a == 2 || a == 1))
                            {
                                valorMenor = distancias[a];
                                switch (a)
                                {
                                    case 1:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2];
                                        break;
                                    case 2:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2];
                                        break;
                                    case 4:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y))[2];
                                        break;
                                    case 5:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2];
                                        break;
                                    case 7:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2];
                                        break;
                                    case 8:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2];
                                        break;
                                }
                            }
                        }
                        (dataPtr + nChan * x + widthStep * y)[0] = valorFinal[0];
                        (dataPtr + nChan * x + widthStep * y)[1] = valorFinal[1];
                        (dataPtr + nChan * x + widthStep * y)[2] = valorFinal[2];
                    }


                    //margem da direita  
                    for (y = 1; y < height - 1; y++)
                    {
                        x = width - 1;
                        distancias = new int[9];
                        count = 0;

                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                        distancias[0] = count;

                        count = 0;
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                        distancias[1] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                        distancias[3] = count;

                        count = 0;
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]);
                        distancias[4] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                        distancias[6] = count;

                        count = 0;
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]);
                        count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                        count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                            Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                        distancias[7] = count;

                        valorMenor = distancias[0];
                        for (int a = 0; a < distancias.Length; a++)
                        {
                            if (distancias[a] < valorMenor && (a == 7 || a == 6 || a == 4 || a == 3 || a == 1 || a == 0))
                            {
                                valorMenor = distancias[a];
                                switch (a)
                                {
                                    case 0:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2];
                                        break;
                                    case 1:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2];
                                        break;
                                    case 3:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2];
                                        break;
                                    case 4:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y))[2];
                                        break;
                                    case 6:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2];
                                        break;
                                    case 7:
                                        valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0];
                                        valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1];
                                        valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2];
                                        break;
                                }
                            }
                        }
                        (dataPtr + nChan * x + widthStep * y)[0] = valorFinal[0];
                        (dataPtr + nChan * x + widthStep * y)[1] = valorFinal[1];
                        (dataPtr + nChan * x + widthStep * y)[2] = valorFinal[2];
                    }


                    //canto superior esquerdo

                    y = 0;
                    x = 0;
                    distancias = new int[9];
                    count = 0;

                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                    count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                    distancias[4] = count;

                    count = 0;
                    count += 4 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                    count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                    distancias[5] = count;

                    count = 0;
                    count += 4 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                    count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2]);
                    distancias[7] = count;

                    count = 0;
                    count += 4 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                    distancias[8] = count;

                    valorMenor = distancias[4];

                    for (int a = 4; a < distancias.Length; a++)
                    {
                        if (distancias[a] < valorMenor)
                        {
                            valorMenor = distancias[a];
                            switch (a)
                            {
                                case 4:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y))[2];
                                    break;
                                case 5:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2];
                                    break;
                                case 7:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2];
                                    break;
                                case 8:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2];
                                    break;
                            }
                        }
                    }
                    (dataPtr + nChan * x + widthStep * y)[0] = valorFinal[0];
                    (dataPtr + nChan * x + widthStep * y)[1] = valorFinal[1];
                    (dataPtr + nChan * x + widthStep * y)[2] = valorFinal[2];


                    //canto superior direito
                    y = 0;
                    x = width - 1;
                    count = 0;

                    count += 4 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]));
                    count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]);
                    distancias[3] = count;

                    count = 0;
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                    count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                    distancias[4] = count;

                    count = 0;
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                    count += 4 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2]));
                    distancias[6] = count;

                    count = 0;
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                    count += 4 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2]);
                    distancias[7] = count;

                    valorMenor = distancias[3];
                    for (int a = 3; a < distancias.Length - 1; a++)
                    {
                        if (distancias[a] < valorMenor)
                        {
                            valorMenor = distancias[a];
                            switch (a)
                            {
                                case 3:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2];
                                    break;
                                case 4:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y))[2];
                                    break;
                                case 6:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2];
                                    break;
                                case 7:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2];
                                    break;
                            }
                        }
                    }
                    (dataPtr + nChan * x + widthStep * y)[0] = valorFinal[0];
                    (dataPtr + nChan * x + widthStep * y)[1] = valorFinal[1];
                    (dataPtr + nChan * x + widthStep * y)[2] = valorFinal[2];


                    //canto inferior esquerdo
                    x = 0;
                    y = height - 1;
                    count = 0;

                    count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                    count += 4 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                    distancias[1] = count;

                    count = 0;
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                    count += 4 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                    distancias[2] = count;

                    count = 0;
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                    count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2]));
                    distancias[4] = count;

                    count = 0;
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                    count += Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2]);
                    count += 4 * (Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    distancias[5] = count;

                    valorMenor = distancias[1];
                    for (int a = 1; a < 6; a++)
                    {
                        if (distancias[a] < valorMenor)
                        {
                            valorMenor = distancias[a];
                            switch (a)
                            {
                                case 1:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2];
                                    break;
                                case 2:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y - 1))[2];
                                    break;
                                case 3:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2];
                                    break;
                                case 4:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y))[2];
                                    break;
                                case 5:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y))[2];
                                    break;
                                case 6:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y + 1))[2];
                                    break;
                                case 7:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y + 1))[2];
                                    break;
                                case 8:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x + 1) + widthStep * (y + 1))[2];
                                    break;
                            }
                        }
                    }
                    (dataPtr + nChan * x + widthStep * y)[0] = valorFinal[0];
                    (dataPtr + nChan * x + widthStep * y)[1] = valorFinal[1];
                    (dataPtr + nChan * x + widthStep * y)[2] = valorFinal[2];


                    //canto inferior direito
                    x = width - 1;
                    y = height - 1;
                    count = 0;

                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                    count += 4 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    distancias[0] = count;

                    count = 0;
                    count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                    count += 4 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    distancias[1] = count;

                    count = 0;
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                    count += Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y))[2]));
                    distancias[3] = count;

                    count = 0;
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2]));
                    count += 2 * (Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2]));
                    count += Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[0] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[1] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1]) +
                        Math.Abs((dataPtrCopy + nChan * (x) + widthStep * (y))[2] - (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2]);
                    distancias[4] = count;

                    valorMenor = distancias[0];
                    for (int a = 0; a < 5; a++)
                    {
                        if (distancias[a] < valorMenor)
                        {
                            valorMenor = distancias[a];
                            switch (a)
                            {
                                case 0:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y - 1))[2];
                                    break;
                                case 1:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y - 1))[2];
                                    break;
                                case 3:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x - 1) + widthStep * (y))[2];
                                    break;
                                case 4:
                                    valorFinal[0] = (dataPtrCopy + nChan * (x) + widthStep * (y))[0];
                                    valorFinal[1] = (dataPtrCopy + nChan * (x) + widthStep * (y))[1];
                                    valorFinal[2] = (dataPtrCopy + nChan * (x) + widthStep * (y))[2];
                                    break;
                            }
                        }
                    }
                    (dataPtr + nChan * x + widthStep * y)[0] = valorFinal[0];
                    (dataPtr + nChan * x + widthStep * y)[1] = valorFinal[1];
                    (dataPtr + nChan * x + widthStep * y)[2] = valorFinal[2];
                }
            }
        }

        public static int[] Histogram_Gray(Emgu.CV.Image<Bgr, byte> img)
        {
            int[] resultado = new int[256];
            unsafe
            {
                MIplImage m = img.MIplImage;

                byte* dataPtrDestino = (byte*)m.imageData.ToPointer();
                int width = img.Width;
                int height = img.Height;
                int nChan = m.nChannels;
                int widthStep = m.widthStep;
                int x, y, media;

                if (nChan == 3)
                {
                    for (x = 0; x < width; x++)
                    {
                        for (y = 0; y < height; y++)
                        {
                            media = (int)Math.Round(((dataPtrDestino + nChan * x + widthStep * y)[0] + (dataPtrDestino + nChan * x + widthStep * y)[1] + (dataPtrDestino + nChan * x + widthStep * y)[2]) / 3.0);
                            resultado[media]++;
                        }
                    }
                }
            }
            return resultado;
        }

        public static void ConvertToBW(Emgu.CV.Image<Bgr, byte> img, int threshold)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;

                byte* dataPtrDestino = (byte*)m.imageData.ToPointer();
                int width = img.Width;
                int height = img.Height;
                int nChan = m.nChannels;
                int widthStep = m.widthStep;
                int x, y;

                if (nChan == 3)
                {
                    for (x = 0; x < width; x++)
                    {
                        for (y = 0; y < height; y++)
                        {
                            int cor = (int)Math.Round(((dataPtrDestino + nChan * x + widthStep * y)[0] + (dataPtrDestino + nChan * x + widthStep * y)[1] + (dataPtrDestino + nChan * x + widthStep * y)[2]) / 3.0);
                            if (cor <= threshold)
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[0] = 0;
                                (dataPtrDestino + nChan * x + widthStep * y)[1] = 0;
                                (dataPtrDestino + nChan * x + widthStep * y)[2] = 0;
                            }
                            else
                            {
                                (dataPtrDestino + nChan * x + widthStep * y)[0] = 255;
                                (dataPtrDestino + nChan * x + widthStep * y)[1] = 255;
                                (dataPtrDestino + nChan * x + widthStep * y)[2] = 255;
                            }
                        }
                    }
                }

            }
        }

        public static void ConvertToBW_Otsu(Emgu.CV.Image<Bgr, byte> img)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                int widthStep = m.widthStep;
                int nChan = m.nChannels;
                byte* dataPtrRead = (byte*)m.imageData.ToPointer();
                int width = img.Width;
                int height = img.Height;

                byte gray;
                double q1 = 0, q2 = 0;
                double u1 = 0, u2 = 0;
                int[] histograma = new int[256];
                double[] otsu = new double[256];

                if (nChan == 3)
                {
                    for (int y = 0; y < height; y++)
                    {
                        for (int x = 0; x < width; x++)
                        {

                            gray = (byte)Math.Round((int)((dataPtrRead + nChan * x + widthStep * y)[0] + (dataPtrRead + nChan * x + widthStep * y)[1] + (dataPtrRead + nChan * x + widthStep * y)[2]) / 3.0);

                            histograma[gray] += 1;
                        }
                    }
                }

                for (int i = 0; i <= 255; i++)
                {
                    q1 = 0; q2 = 0; u1 = 0; u2 = 0;

                    for (int j = 0; j <= i; j++)
                    {

                        q1 += histograma[j] / (double)(width * height);
                        u1 += (j * histograma[j]) / (double)(width * height);
                    }
                    u1 /= q1;

                    for (int k = i + 1; k <= 255; k++)
                    {
                        q2 += histograma[k] / (double)(width * height);
                        u2 += (k * histograma[k]) / (double)(width * height);

                    }
                    u2 /= q2;

                    otsu[i] = q1 * q2 * ((u1 - u2) * (u1 - u2));
                }

                int threshold = Array.IndexOf(otsu, otsu.Max());
                ConvertToBW(img, threshold);
            }
        }


        //Projeto
        public static Image<Bgr, byte> Signs(Image<Bgr, byte> img, Image<Bgr, byte> imgCopy, out List<string[]> limitSign, out List<string[]> warningSign, out List<string[]> prohibitionSign, int level)
        {
            Image<Bgr, byte> img_hsv_red = img.Copy();
            Image<Bgr, byte> img_sinal_redondo = img.Copy();
            Image<Bgr, byte> img_hsv_black = img.Copy();
            Image<Bgr, byte> img_hsv_blue = img.Copy();
            Image<Bgr, byte> img_sinal_recortado = img.Copy();

            limitSign = new List<string[]>();
            warningSign = new List<string[]>();
            prohibitionSign = new List<string[]>();
            List <string[]> informationSign = new List<string[]>();
            List <string[]> stopSign = new List<string[]>();

            List<Image<Bgr, byte>> numerosBD = new List<Image<Bgr, byte>>();
            var path = "D:/CG/precurso/ProjetoRecurso/numeros/";

            for (int i = 0; i < 10; i++)
            {
                Image<Bgr, byte> numero = new Image<Bgr, byte>(path + i + ".PNG");
                numerosBD.Add(numero);
            }

            Hsv_red(img_hsv_red);
            int [,] listaDeEtiquetas = Etiquetas(img_hsv_red);
            List<int[]> listaDeSinais = CoordSinal(listaDeEtiquetas, img.Height, img.Width, 0, false);

            foreach(var sinal in listaDeSinais)
            {
                Rectangle recorte = new Rectangle(sinal[1], sinal[2], sinal[3] - sinal[1], sinal[4] - sinal[2]);
                img_sinal_recortado = img_hsv_red.Copy(recorte);

                int tipoDeSinal = tipo_de_sinal(img_sinal_recortado);
                if(tipoDeSinal == 0)
                {
                    img_sinal_redondo = img.Copy(recorte);
                    Hsv_red(img_sinal_redondo);
                    listaDeEtiquetas = Etiquetas(img_sinal_redondo);
                    List<int[]> quantidadeDeEtiquetas = CoordSinal(listaDeEtiquetas, img_sinal_redondo.Height, img_sinal_redondo.Width, 1, false);
                    if(quantidadeDeEtiquetas.Count > 1)
                    {
                        string[] proibicao = new string[5];
                        proibicao[0] = "-1";  // value -1
                        proibicao[1] = sinal[1].ToString(); // Left-x
                        proibicao[2] = sinal[2].ToString(); // Top-y
                        proibicao[3] = sinal[3].ToString(); // Right-x
                        proibicao[4] = sinal[4].ToString(); // Bottom-y

                        prohibitionSign.Add(proibicao);
                    }
                    else
                    {
                        unsafe
                        {
                            MIplImage m = img_sinal_redondo.MIplImage;
                            int widthStep = m.widthStep;
                            int nChan = m.nChannels;
                            byte* dataPtr = (byte*)m.imageData.ToPointer();
                            var centro = (dataPtr + nChan * (img_sinal_redondo.Width / 2) + widthStep * (img_sinal_redondo.Height / 2))[0];
                            
                            if(centro != 255)
                            {
                                img_hsv_black = img.Copy(recorte);
                                Hsv_black(img_hsv_black);
                                listaDeEtiquetas = Etiquetas(img_hsv_black);
                                List<int[]> EtiquetasNumeros = CoordSinal(listaDeEtiquetas, img_sinal_redondo.Height, img_sinal_redondo.Width, 1, true);
                                EtiquetasNumeros = ordenarEtiquetas(EtiquetasNumeros); 

                                ArrayList numerosRedimencionados = new ArrayList();
                                foreach (var num in numerosBD)
                                {
                                    Hsv_black(num);
                                    var image_bitmap = new Bitmap(num.Copy().Bitmap, new Size(110, 110));
                                    image_bitmap.SetResolution(300, 300);
                                    Image<Bgr, byte> numeroDaBD = new Image<Bgr, byte>(image_bitmap);
                                    numerosRedimencionados.Add(numeroDaBD);
                                }

                                String NumeroString = "";
                                foreach (var aux in EtiquetasNumeros)
                                {
                                    Image<Bgr, byte> numeroRec = img.Copy();
                                    Rectangle numeroRecortado = new Rectangle(aux[1], aux[2], aux[3] - aux[1], aux[4] - aux[2]);
                                    numeroRec = img_hsv_black.Copy(numeroRecortado);

                                    var image_bitmap = new Bitmap(numeroRec.Copy().Bitmap, new Size(110, 110));
                                    image_bitmap.SetResolution(300, 300);
                                    Image<Bgr, byte> NumeroDaImagem = new Image<Bgr, byte>(image_bitmap);

                                    NumeroString = NumeroString + numerosComparar(NumeroDaImagem, numerosRedimencionados);
                                }

                                if (NumeroString == "" || int.Parse(NumeroString) % 10 != 0)
                                {
                                    string[] proibicao = new string[5];
                                    proibicao[0] = "-1";  // value -1
                                    proibicao[1] = sinal[1].ToString(); // Left-x
                                    proibicao[2] = sinal[2].ToString(); // Top-y
                                    proibicao[3] = sinal[3].ToString(); // Right-x
                                    proibicao[4] = sinal[4].ToString(); // Bottom-y

                                    prohibitionSign.Add(proibicao);
                                }
                                else
                                {
                                    string[] sinalVelocidade = new string[5];
                                    sinalVelocidade[0] = NumeroString;  // speed limit
                                    sinalVelocidade[1] = sinal[1].ToString(); // Left-x
                                    sinalVelocidade[2] = sinal[2].ToString(); // Top-y
                                    sinalVelocidade[3] = sinal[3].ToString(); // Right-x
                                    sinalVelocidade[4] = sinal[4].ToString(); // Bottom-y

                                    limitSign.Add(sinalVelocidade);
                                }
                            }
                            else
                            {
                                string[] proibicao = new string[5];
                                proibicao[0] = "-1";  // value -1
                                proibicao[1] = sinal[1].ToString(); // Left-x
                                proibicao[2] = sinal[2].ToString(); // Top-y
                                proibicao[3] = sinal[3].ToString(); // Right-x
                                proibicao[4] = sinal[4].ToString(); // Bottom-y

                                prohibitionSign.Add(proibicao);
                            }
                        }
                    }
                }
                else if(tipoDeSinal == 1)
                {

                    string[] warning = new string[5];
                    warning[0] = "-1";  // value -1
                    warning[1] = sinal[1].ToString(); // Left-x
                    warning[2] = sinal[2].ToString(); // Top-y
                    warning[3] = sinal[3].ToString(); // Right-x
                    warning[4] = sinal[4].ToString(); // Bottom-y

                    warningSign.Add(warning);
                }
                else if(tipoDeSinal == 2)
                {
                    Console.WriteLine("STOP");

                    string[] stop = new string[5];
                    stop[0] = "-1";  // value -1
                    stop[1] = sinal[1].ToString(); // Left-x
                    stop[2] = sinal[2].ToString(); // Top-y
                    stop[3] = sinal[3].ToString(); // Right-x
                    stop[4] = sinal[4].ToString(); // Bottom-y

                    stopSign.Add(stop);
                }
            }


            Hsv_blue(img_hsv_blue);
            var etiquetasAzuis = Etiquetas(img_hsv_blue);
            var listaSinaisAzuis = CoordSinal(etiquetasAzuis, img_hsv_blue.Height, img_hsv_blue.Width, 2, false);
            foreach(var sinalInfo in listaSinaisAzuis)
            {
                Rectangle rect = new Rectangle(sinalInfo[1], sinalInfo[2], sinalInfo[3] - sinalInfo[1], sinalInfo[4] - sinalInfo[2]);
                Image<Bgr, byte> imgAux = img_hsv_blue.Copy(rect);
                
                Console.WriteLine("Sinal de informação azul");

                string[] info = new string[5];
                info[0] = "-1";  // value -1
                info[1] = sinalInfo[1].ToString(); // Left-x
                info[2] = sinalInfo[2].ToString(); // Top-y
                info[3] = sinalInfo[3].ToString(); // Right-x
                info[4] = sinalInfo[4].ToString(); // Bottom-y

                informationSign.Add(info);
            }
            MarcarSinais(img, limitSign, 1);
            MarcarSinais(img, warningSign, 2);
            MarcarSinais(img, prohibitionSign, 3);
            MarcarSinais(img, informationSign, 4);
            MarcarSinais(img, stopSign, 4);

            return img;
        }

        public static void Hsv_red(Image<Bgr, byte> img)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                int widthStep = m.widthStep;
                int nChan = m.nChannels;
                byte* dataPtr = (byte*)m.imageData.ToPointer();
                int width = img.Width;
                int height = img.Height;
                double max = 0.0, min = 0.0, h = 0.0, v = 0.0, s = 0.0;

                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        double blue = (dataPtr + nChan * x + widthStep * y)[0] / 255.0;
                        double green = (dataPtr + nChan * x + widthStep * y)[1] / 255.0;
                        double red = (dataPtr + nChan * x + widthStep * y)[2] / 255.0;

                        if (red > blue && red > green)
                        {
                            max = red;
                            if (green > blue)
                            { min = blue; }
                            else
                            { min = green; }
                        }
                        else if (green > red && green > blue)
                        {
                            max = green;
                            if (red > blue)
                            { min = blue; }
                            else
                            { min = red; }
                        }
                        else
                        {
                            max = blue;
                            if (green > red)
                            { min = red; }
                            else
                            { min = green; }
                        }


                        if (red == max && green >= blue)
                        {
                            h = 60 * ((green - blue) / (max - min));
                        }
                        else if (red == max && green < blue)
                        {
                            h = 60 * ((green - blue) / (max - min)) + 360;
                        }
                        else if (green == max)
                        {
                            h = 60 * ((blue - red) / (max - min)) + 120;
                        }
                        else if (blue == max)
                        {
                            h = 60 * ((red - green) / (max - min)) + 240;
                        }

                        if (max > 0)
                        { s = (max - min) / max; }
                        else
                        { s = 0; }

                        v = max;

                        if ((h < 10 || h > 340) && s > 0.30)
                        {
                            (dataPtr + nChan * x + widthStep * y)[0] = 255;
                            (dataPtr + nChan * x + widthStep * y)[1] = 255;
                            (dataPtr + nChan * x + widthStep * y)[2] = 255;
                        }
                        else
                        {
                            (dataPtr + nChan * x + widthStep * y)[0] = 0;
                            (dataPtr + nChan * x + widthStep * y)[1] = 0;
                            (dataPtr + nChan * x + widthStep * y)[2] = 0;
                        }
                    }
                }
            }
        }

        public static void Hsv_black(Image<Bgr, byte> img)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                int widthStep = m.widthStep;
                int nChan = m.nChannels;
                byte* dataPtr = (byte*)m.imageData.ToPointer();
                int width = img.Width;
                int height = img.Height;
                double max = 0.0;
                double min = 0.0;
                double h = 0.0;
                double v = 0.0;
                double s = 0.0;

                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        double blue = (dataPtr + nChan * x + widthStep * y)[0] / 255.0;
                        double green = (dataPtr + nChan * x + widthStep * y)[1] / 255.0;
                        double red = (dataPtr + nChan * x + widthStep * y)[2] / 255.0;

                        if (red > blue && red > green)
                        {
                            max = red;
                            if (green > blue)
                            { min = blue; }
                            else
                            { min = green; }
                        }
                        else if (green > red && green > blue)
                        {
                            max = green;
                            if (red > blue)
                            { min = blue; }
                            else
                            { min = red; }
                        }
                        else
                        {
                            max = blue;
                            if (green > red)
                            { min = red; }
                            else
                            { min = green; }
                        }


                        if (red == max && green >= blue)
                        {
                            h = 60 * ((green - blue) / (max - min));
                        }
                        else if (red == max && green < blue)
                        {
                            h = 60 * ((green - blue) / (max - min)) + 360;
                        }
                        else if (green == max)
                        {
                            h = 60 * ((blue - red) / (max - min)) + 120;
                        }
                        else if (blue == max)
                        {
                            h = 60 * ((red - green) / (max - min)) + 240;
                        }

                        if (max > 0)
                        { s = (max - min) / max; }
                        else
                        { s = 0; }

                        v = max;

                        if (v < 0.50 && s < 0.65)
                        {
                            (dataPtr + nChan * x + widthStep * y)[0] = 255;
                            (dataPtr + nChan * x + widthStep * y)[1] = 255;
                            (dataPtr + nChan * x + widthStep * y)[2] = 255;
                        }
                        else
                        {
                            (dataPtr + nChan * x + widthStep * y)[0] = 0;
                            (dataPtr + nChan * x + widthStep * y)[1] = 0;
                            (dataPtr + nChan * x + widthStep * y)[2] = 0;
                        }
                    }
                }
            }
        }

        public static void Hsv_blue(Image<Bgr, byte> img)
        {
            unsafe
            {
                MIplImage m = img.MIplImage;
                int widthStep = m.widthStep;
                int nChan = m.nChannels;
                byte* dataPtr = (byte*)m.imageData.ToPointer();
                int width = img.Width;
                int height = img.Height;
                double max = 0.0;
                double min = 0.0;
                double h = 0.0;
                double v = 0.0;
                double s = 0.0;

                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        double blue = (dataPtr + nChan * x + widthStep * y)[0] / 255.0;
                        double green = (dataPtr + nChan * x + widthStep * y)[1] / 255.0;
                        double red = (dataPtr + nChan * x + widthStep * y)[2] / 255.0;

                        if (red > blue && red > green)
                        {
                            max = red;
                            if (green > blue)
                            { min = blue; }
                            else
                            { min = green; }
                        }
                        else if (green > red && green > blue)
                        {
                            max = green;
                            if (red > blue)
                            { min = blue; }
                            else
                            { min = red; }
                        }
                        else
                        {
                            max = blue;
                            if (green > red)
                            { min = red; }
                            else
                            { min = green; }
                        }


                        if (red == max && green >= blue)
                        {
                            h = 60 * ((green - blue) / (max - min));
                        }
                        else if (red == max && green < blue)
                        {
                            h = 60 * ((green - blue) / (max - min)) + 360;
                        }
                        else if (green == max)
                        {
                            h = 60 * ((blue - red) / (max - min)) + 120;
                        }
                        else if (blue == max)
                        {
                            h = 60 * ((red - green) / (max - min)) + 240;
                        }

                        if (max > 0)
                        { s = (max - min) / max; }
                        else
                        { s = 0; }

                        v = max;

                        if ((h > 180 && h < 290) && s > 0.80)
                        {
                            (dataPtr + nChan * x + widthStep * y)[0] = 255;
                            (dataPtr + nChan * x + widthStep * y)[1] = 255;
                            (dataPtr + nChan * x + widthStep * y)[2] = 255;
                        }
                        else
                        {
                            (dataPtr + nChan * x + widthStep * y)[0] = 0;
                            (dataPtr + nChan * x + widthStep * y)[1] = 0;
                            (dataPtr + nChan * x + widthStep * y)[2] = 0;
                        }
                    }
                }
            }
        }

        public static int[,] Etiquetas(Image<Bgr, byte> img)
        {
            int[,] etiquetas = new int[img.Height, img.Width];
            unsafe
            {
                MIplImage m = img.MIplImage;
                byte* dataPtr = (byte*)m.imageData.ToPointer(); // Pointer to the image
                int etiqueta = 1;
                int nChan = m.nChannels;
                int widthStep = m.widthStep;
                int y, x, Height = img.Height, Width = img.Width;
                Boolean troca = false;

                for (y = 0; y < Height; y++)
                {
                    for (x = 0; x < Width; x++)
                    {
                        if ((dataPtr + nChan * x + widthStep * y)[0] == 255)
                        {
                            etiquetas[y, x] = etiqueta;
                            etiqueta++;
                        }
                    }
                }

                while (true)
                {
                    for (y = 1; y < Height - 1; y++)
                    {
                        for (x = 1; x < Width - 1; x++)
                        {
                            if (etiquetas[y, x] != 0)
                            {
                                if (etiquetas[y, x] > etiquetas[y - 1, x] && etiquetas[y - 1, x] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y - 1, x];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y, x - 1] && etiquetas[y, x - 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y, x - 1];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y, x + 1] && etiquetas[y, x + 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y, x + 1];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y + 1, x] && etiquetas[y + 1, x] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y + 1, x];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y - 1, x - 1] && etiquetas[y - 1, x - 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y - 1, x - 1];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y - 1, x + 1] && etiquetas[y - 1, x + 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y - 1, x + 1];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y + 1, x - 1] && etiquetas[y + 1, x - 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y + 1, x - 1];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y + 1, x + 1] && etiquetas[y + 1, x + 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y + 1, x + 1];
                                    troca = true;
                                }
                            }
                        }
                    }

                    if (troca == false)
                    {
                        break;
                    }
                    troca = false;

                    for (y = Height - 2; y > 1; y--)
                    {
                        for (x = Width - 2; x > 1; x--)
                        {
                            if (etiquetas[y, x] != 0)
                            {
                                if (etiquetas[y, x] > etiquetas[y - 1, x] && etiquetas[y - 1, x] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y - 1, x];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y, x - 1] && etiquetas[y, x - 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y, x - 1];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y, x + 1] && etiquetas[y, x + 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y, x + 1];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y + 1, x] && etiquetas[y + 1, x] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y + 1, x];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y - 1, x - 1] && etiquetas[y - 1, x - 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y - 1, x - 1];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y - 1, x + 1] && etiquetas[y - 1, x + 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y - 1, x + 1];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y + 1, x - 1] && etiquetas[y + 1, x - 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y + 1, x - 1];
                                    troca = true;
                                }
                                if (etiquetas[y, x] > etiquetas[y + 1, x + 1] && etiquetas[y + 1, x + 1] != 0)
                                {
                                    etiquetas[y, x] = etiquetas[y + 1, x + 1];
                                    troca = true;
                                }
                            }
                        }
                    }
                    if (troca == false)
                    {
                        break;
                    }
                    troca = false;

                }


            }
            return etiquetas;
        }

        public static List<int[]> CoordSinal(int[,] etiquetas, int height, int width, int tipo, Boolean numeros)
        {
            List<int[]> listaDeSinais = new List<int[]>();
            List<int> lista = new List<int>();
            List<int> listaAux = new List<int>();

            for (int y = 0; y < height; y++)
            {
                for (int x = 0; x < width; x++)
                {
                    if (etiquetas[y, x] > 0 && !lista.Contains(etiquetas[y, x]))
                    {
                        lista.Add(etiquetas[y, x]);
                    }
                }
            }

            for (int i = 0; i < lista.Count; i++)
            {
                double count = 0.0;

                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        if (etiquetas[y, x] == lista[i])
                        {
                            count++;
                        }
                    }
                }
                if (tipo == 0)
                {
                    if (count > 100)
                    {
                        listaAux.Add(lista[i]);
                    }
                }
                else if(tipo == 1)
                {
                    if (numeros)
                    {
                        if (count > 140)
                        {
                            listaAux.Add(lista[i]);
                        }
                    }
                    else
                    {
                        if (count > 45)
                        {
                            listaAux.Add(lista[i]);
                        }
                    }
                }
                else if(tipo == 2)
                {
                    if (count > 500)
                    {
                        listaAux.Add(lista[i]);
                    }
                }   
            }

            for (int i = 0; i < listaAux.Count; i++)
            {

                int xL = width - 1;
                int xR = 0;
                int yT = height - 1;
                int yB = 0;

                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        if (etiquetas[y, x] == listaAux[i])
                        {
                            if (xL > x)
                            {
                                xL = x;
                                break;
                            }
                        }
                    }
                }

                for (int y = height - 1; y > 0; y--)
                {
                    for (int x = width - 1; x > 0; x--)
                    {
                        if (etiquetas[y, x] == listaAux[i])
                        {
                            if (xR < x)
                            {
                                xR = x;
                                break;
                            }
                        }
                    }
                }

                for (int x = 0; x < width; x++)
                {
                    for (int y = height - 1; y > 0; y--)
                    {
                        if (etiquetas[y, x] == listaAux[i])
                        {
                            if (yB < y)
                            {
                                yB = y;
                                break;
                            }
                        }
                    }
                }

                for (int x = 0; x < width; x++)
                {
                    for (int y = 0; y < height; y++)
                    {
                        if (etiquetas[y, x] == listaAux[i])
                        {
                            if (yT > y)
                            {
                                yT = y;
                                break;
                            }
                        }
                    }
                }
                if (numeros)
                {
                    if (!(yT < height * 0.1 || yB > height * 0.9 || xL < width * 0.1 || xR > width * 0.9))
                    {
                        int[] Sinal = new int[5];
                        Sinal[0] = listaAux[i];   // Nº Etiqueta
                        Sinal[1] = xL; // Left-x
                        Sinal[2] = yT;  // Top-y
                        Sinal[3] = xR; // Right-x
                        Sinal[4] = yB;  // Bottom-y

                        listaDeSinais.Add(Sinal);
                    }
                }
                else
                {
                    int[] Sinal = new int[5];
                    Sinal[0] = listaAux[i]; // Nº Etiqueta
                    Sinal[1] = xL; // Left-x
                    Sinal[2] = yT;  // Top-y
                    Sinal[3] = xR; // Right-x
                    Sinal[4] = yB;  // Bottom-y

                    listaDeSinais.Add(Sinal);
                }
                
            }
            if (tipo == 0)
            {
                double max = 0.0;
                for (int i = 0; i < listaDeSinais.Count; i++)
                {
                    double count = (listaDeSinais[i][3] - listaDeSinais[i][1]) * (listaDeSinais[i][4] - listaDeSinais[i][2]);

                    if (max < count)
                    {
                        max = count;
                    }
                }
                for (int i = 0; i < listaDeSinais.Count; i++)
                {
                    double count = (listaDeSinais[i][3] - listaDeSinais[i][1]) * (listaDeSinais[i][4] - listaDeSinais[i][2]);

                    if ((count / max) < 0.17)
                    {
                        listaDeSinais.Remove(listaDeSinais[i]);
                        i--;
                    }
                }
            }
            else if(tipo == 2)
            {
                double max = 0.0;
                for (int i = 0; i < listaDeSinais.Count; i++)
                {
                    double count = (listaDeSinais[i][3] - listaDeSinais[i][1]) * (listaDeSinais[i][4] - listaDeSinais[i][2]);

                    if (max < count)
                    {
                        max = count;
                    }
                }
                for (int i = 0; i < listaDeSinais.Count; i++)
                {
                    double count = (listaDeSinais[i][3] - listaDeSinais[i][1]) * (listaDeSinais[i][4] - listaDeSinais[i][2]);

                    if ((count / max) < 0.6)
                    {
                        listaDeSinais.Remove(listaDeSinais[i]);
                        i--;
                    }
                }
            }
            
            return listaDeSinais;
        }

        public static int tipo_de_sinal(Image<Bgr, byte> img)
        {
            int aux = -1;
            unsafe
            {
                MIplImage m = img.MIplImage;
                int width = img.Width;
                int height = img.Height;
                int widthStep = m.widthStep;
                int nChan = m.nChannels;
                byte* dataPtr = (byte*)m.imageData.ToPointer();

                int xL = width - 1;
                int yL = 0;

                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        if ((dataPtr + nChan * x + widthStep * y)[0] == 255)
                        {
                            if (x < xL)
                            {
                                xL = x;
                                yL = y;
                                break;
                            }
                        }
                    }
                }

                int gap = Convert.ToInt32(height * 0.15);

                if (yL > (height / 2) - gap && yL < (height / 2) + gap)
                {
                    aux = 0;
                }
                else
                {
                    aux = 1;
                }

                double count = 0.0;

                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        if ((dataPtr + nChan * x + widthStep * y)[0] == 255)
                        {
                            count++;
                        }
                    }
                }

                if(count/(img.Height*img.Width) > 0.55)
                {
                    aux = 2;
                }
                return aux;
            }
        }

        public static String numerosComparar(Image<Bgr, byte> img, ArrayList numerosBD)
        {
            unsafe
            {

                List<int> listaDiferencas = new List<int>();
                MIplImage m = img.MIplImage;
                byte* dataPtr = (byte*)m.imageData.ToPointer();

                int width = img.Width;
                int height = img.Height;
                int nChan = m.nChannels;
                int widthStep = m.widthStep;

                foreach (Image<Bgr, byte> numeroBD in numerosBD)
                {
                    int diferenca = 0;

                    MIplImage m2 = numeroBD.MIplImage;
                    byte* dataPtr2 = (byte*)m2.imageData.ToPointer();
                    int nChan2 = m2.nChannels;
                    int widthStep2 = m2.widthStep;

                    for (int y = 0; y < height; y++)
                    {
                        for (int x = 0; x < width; x++)
                        {
                            if ((dataPtr + nChan * x + widthStep * y)[2] != (dataPtr2 + nChan2 * x + widthStep2 * y)[2])
                            {
                                diferenca++;
                            }
                        }
                    }
                    listaDiferencas.Add(diferenca);
                }
                double minimo = listaDiferencas.Min();
                if (minimo / (110 * 110) > 0.50)
                {
                    return "";
                }
                return listaDiferencas.IndexOf(listaDiferencas.Min()).ToString();
            }
        }

        public static List<int[]> ordenarEtiquetas(List<int[]> posicoes)
        {
            return posicoes.OrderBy(x => x[1]).ToList();
        }

        public static void tipoDeTriangulo(Image<Bgr, byte> img, string[] sinal)
        {
            unsafe
            {   
                Rectangle rect = new Rectangle(int.Parse(sinal[1]), int.Parse(sinal[2]), int.Parse(sinal[3]) - int.Parse(sinal[1]), int.Parse(sinal[4]) - int.Parse(sinal[2]));
                Image<Bgr, byte>  img_ = img.Copy(rect);
                Hsv_red(img_);

                MIplImage aux = img_.MIplImage;
                int widthStep = aux.widthStep;
                int nChan = aux.nChannels;
                byte* dataPtr = (byte*)aux.imageData.ToPointer();

                int xL = img_.Width - 1;

                for (int y = 0; y < img_.Height - img_.Height * 0.85; y++)
                {
                    for (int x = 0; x < img.Width; x++)
                    {
                        if ((dataPtr + nChan * x + widthStep * y)[0] == 255)
                        {
                            if (xL > x)
                            {
                                xL = x;
                                break;
                            }
                        }
                    }
                }

                if (xL < 15)
                {
                    Console.WriteLine("Sinal de Warning, Sinal de cedencia de passagem (triangulo virado para baixo)");
                }
                else
                {
                    Console.WriteLine("Sinal de Warning, Sinal de perigo (triangulo virado para cima)");
                }
            }
        }

        public static void MarcarSinais(Image<Bgr, byte> img, List<string[]> sinais, int tipo)
        {
            unsafe
            {
                foreach (string[] sinal in sinais)
                {
                    MIplImage m = img.MIplImage;
                    byte* dataPtr = (byte*)m.imageData.ToPointer();

                    int widthStep = m.widthStep;
                    int nChan = m.nChannels;

                    int xLeft = int.Parse(sinal[1]);
                    int yTop = int.Parse(sinal[2]);
                    int xRight = int.Parse(sinal[3]);
                    int yBottom = int.Parse(sinal[4]);

                    int tamanho = 4;

                    if(xLeft < 4)
                    {
                        xLeft += 4;
                    }
                    if(xRight < img.Width - 4)
                    {
                        xRight -= 4;
                    }

                    for (int y = yTop; y < yBottom; y++)
                    {
                        for (int n = 0; n < tamanho; n++)
                        {
                            (dataPtr + y * widthStep + (xLeft - n) * nChan)[0] = 50;
                            (dataPtr + y * widthStep + (xLeft - n) * nChan)[1] = 150;
                            (dataPtr + y * widthStep + (xLeft - n) * nChan)[2] = 255;

                            (dataPtr + y * widthStep + (xRight + n) * nChan)[0] = 50;
                            (dataPtr + y * widthStep + (xRight + n) * nChan)[1] = 150;
                            (dataPtr + y * widthStep + (xRight + n) * nChan)[2] = 255;
                        }

                    }

                    if (yTop < 4)
                    {
                        yTop += 4;
                    }
                    if (yBottom > img.Height - 4)
                    {
                        yBottom -= 4;
                    }

                    for (int x = xLeft; x < xRight; x++)
                    {
                        for (int n = 0; n < tamanho; n++)
                        {
                            (dataPtr + (yTop - n) * widthStep + x * nChan)[0] = 50;
                            (dataPtr + (yTop - n) * widthStep + x * nChan)[1] = 150;
                            (dataPtr + (yTop - n) * widthStep + x * nChan)[2] = 255;

                            (dataPtr + (yBottom + n) * widthStep + x * nChan)[0] = 50;
                            (dataPtr + (yBottom + n) * widthStep + x * nChan)[1] = 150;
                            (dataPtr + (yBottom + n) * widthStep + x * nChan)[2] = 255;
                        }
                    }

                    if (tipo == 1)
                    {
                        Console.WriteLine("Sinal de limite, com velocidade máxima de " + sinal[0] + " KM/H");
                    }
                    else if (tipo == 2)
                    {
                        tipoDeTriangulo(img , sinal);
                    }
                    else if (tipo == 3)
                    {
                        Console.WriteLine("Sinal de proibição");
                    }
                }
            }
        }

    }
}
