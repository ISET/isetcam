#include "mex.h"
#include <stdio.h>
#include <sys/types.h>
#include "jpeglib.h"


/*
 * Simple jpeg reading MEX-file. 
 *
 * Calls the jpeg library which is part of 
 * "The Independent JPEG Group's JPEG software" collection.
 *
 * The jpeg library came from,
 *
 * ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6.tar.gz
 */

void mexFunction(int nlhs, Matrix *plhs[],
                 int nrhs, Matrix *prhs[]) { 
  FILE * infile;
  JSAMPARRAY buffer;
  Matrix *mp_red, *mp_green, *mp_blue;
  double *pr_red, *pr_green, *pr_blue;
  long i,j,k,row_stride;
  char filename[64];
  struct jpeg_decompress_struct cinfo;
  struct jpeg_error_mgr jerr;

  if (nrhs < 1 || mxIsNumeric(prhs[0]))
    mexErrMsgTxt("Not enough input arguments, or first argument is not a string");

  mxGetString(prhs[0],filename,64);  /* First argument is the filename */

/*
 * Initialize the jpeg library
 */

  cinfo.err = jpeg_std_error(&jerr);
  jpeg_create_decompress(&cinfo);

/*
 * Open jpg file
 */

  if ((infile = fopen(filename, "rb")) == NULL) {
    mexErrMsgTxt("Couldn't open file");
  }

/*
 * Read the jpg header to get info about size and color depth
 */

  jpeg_stdio_src(&cinfo, infile);
  jpeg_read_header(&cinfo, TRUE);
  jpeg_start_decompress(&cinfo);
  if (cinfo.output_components == 1) { /* Grayscale */
    jpeg_destroy_decompress(&cinfo);
    mexErrMsgTxt("Grayscale jpegs not supported");
  }

/*
 * Allocate buffer for one scan line
 */

  row_stride = cinfo.output_width * cinfo.output_components;
  buffer = (*cinfo.mem->alloc_sarray)
                ((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);

/*
 * Create 3 matrices, One each for the Red, Green, and Blue componenet of the image.
 */

  mp_red = mxCreateFull(cinfo.output_height,cinfo.output_width, REAL);
  mp_green = mxCreateFull(cinfo.output_height,cinfo.output_width, REAL);
  mp_blue = mxCreateFull(cinfo.output_height,cinfo.output_width, REAL);

/*
 * Get pointers to the real part of each matrix (data is stored in a 1 dimensional
 * double array).
 */

  pr_red = mxGetPr(mp_red);pr_green = mxGetPr(mp_green);pr_blue = mxGetPr(mp_blue);

/*
 * Now, loop thru each of the scanlines. For each, copy the image
 * data from the buffer, convert to double, rescale from
 * [0 255] to [0 1] and store in the RGB matrices.
 */

  while (cinfo.output_scanline < cinfo.output_height) {
     jpeg_read_scanlines(&cinfo, buffer,1);
     for (i=0;i<cinfo.output_width;i++) {
       j=(i)*cinfo.output_height+cinfo.output_scanline-1;
       pr_red[j]   = ((double)buffer[0][i*3+0])/255;
       pr_green[j] = ((double)buffer[0][i*3+1])/255;
       pr_blue[j]  = ((double)buffer[0][i*3+2])/255;
     }
  }

/*
 * Clean up
 */

  jpeg_finish_decompress(&cinfo); fclose(infile);
  jpeg_destroy_decompress(&cinfo);

/*
 * Give the mexfile output arguments by making the
 * pointer to left hand side point to the RGB matrices.
 */

  plhs[0]=mp_red; plhs[1]=mp_green; plhs[2]=mp_blue;
  return;		
}

