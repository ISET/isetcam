/*
 * Simple jpeg writing MEX-file. 
 *
 * Synopsis:
 *   jpgwrite(filename,r,g,b,quality)
 *
 * jpgwrite is a matlab mex file, based on jpgread by Drea Thomas and the 
 * examples in the IJG distribution.
 *
 * Calls the jpeg library which is part of 
 * "The Independent JPEG Group's JPEG software" collection.
 *
 * The jpeg library came from,
 *
 * ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6.tar.gz
 * 
 * The RHS inputs 
 *   filename: String for output file name
 *   r,g,b:    Data for the R,G and B image planes.  Doubles, I think.  Between 0 and 1?
 *   quality:  Can be a scalar, or it can be a matrix whose 3 rows are
 *             the 3x64 entries of the quantization table.  In this case
 *             each row is an 8x8 quantization table for the R,G or B planes.
 *
 *   Updated this file for compilation 2/10/03 -- BW
 *   Failed to find a dll for the jpeg libraries, though.  So, the linking
 *   stage fails when using mex.  Need to find the library and figure out how this works. 
 */
 
#include <stdio.h>
#include <sys/types.h>
#include "jpeglib.h"
#include "mex.h"

/* Gateway function for all mex routines */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) { 
  FILE *outfile, *junk;
  JSAMPARRAY buffer;
  /* mxArray *mp_red, *mp_green, *mp_blue; */
  double *pr_red, *pr_green, *pr_blue, *pr_qtable;
  long i,j,row_stride,image_width,image_height;
  char filename[64];
  struct jpeg_compress_struct cinfo;
  struct jpeg_error_mgr jerr;
  int quality, num_qtable, qtable_size;
  unsigned int qtable[64];

  if (nrhs < 4 || mxIsNumeric(prhs[0])){
    mexErrMsgTxt("Not enough input arguments, or first argument is not a string");
  }
  
  if (nrhs < 5) {
    quality = 75;  /*  default image quality  */
    qtable_size = 1;
    num_qtable = 2;
  } 
  else {
    /* mxGetM Reads the size of the input array */
    qtable_size = mxGetM(prhs[4]);   /* Row*Col? */
    
    /* If qtable is a scalar, set it now.  Also sets num_qtable, whatever that is?  */
    if (qtable_size==1) {
      quality = mxGetScalar(prhs[4]);
      num_qtable = 2;
    }
    else {
      quality = 50;    /* so that quant table is used as is */
      num_qtable = mxGetN(prhs[4]);
    }
  }
  if (num_qtable>3) num_qtable = 3;

  mxGetString(prhs[0],filename,64);  /* First argument is the filename */
  image_height = mxGetM(prhs[1]);
  image_width = mxGetN(prhs[1]);
  
/*
 * Initialize the jpeg library
 */

  cinfo.err = jpeg_std_error(&jerr);
  jpeg_create_compress(&cinfo);

/*
 * Open jpg file
 */

  if ((outfile = fopen(filename, "wb")) == NULL) {
    mexErrMsgTxt("Couldn't open file ");
  }

/*
 * Read the jpg header to get info about size and color depth
 */

  jpeg_stdio_dest(&cinfo, outfile);

/*
 * set parameters for compression
 */

  cinfo.image_width = image_width; 	/* image width and height, in pixels */
  cinfo.image_height = image_height;
  cinfo.input_components = 3;		/* # of color components per pixel */
  cinfo.in_color_space = JCS_RGB; 	/* colorspace of input image */
  jpeg_set_defaults(&cinfo);

/* set sampling factors to disable downsampling - how?
  cinfo.comp_info[0].h_samp_factor = 1;
  cinfo.comp_info[0].v_samp_factor = 1;
*/

  /* use standard tables if quantization tables not provided */
  jpeg_set_quality(&cinfo, quality, TRUE /* limit to baseline-JPEG values*/);

  /* set custom quantization tables if provided */
  if (qtable_size==64) {
    quality = jpeg_quality_scaling(quality);
    pr_qtable = mxGetPr(prhs[4]);

    for (j=0; j<num_qtable; j++) {
      for (i=0; i<64; i++) {
        qtable[i] = (unsigned int) pr_qtable[i+64*j];
      }
      jpeg_add_quant_table(&cinfo, j, qtable, quality, TRUE);
      cinfo.comp_info[j].quant_tbl_no = j;
    }
  }

  /* DEBUG: write out the quantization table in the file "test"
  junk = fopen("test", "w");
  for (j=0; j<num_qtable; j++) {
    for (i=0; i<64; i++) {
      fprintf(junk, "%d ", (UINT16) (cinfo.quant_tbl_ptrs[j]->quantval[i]));
      if (i%8 == 7) fprintf(junk, "\n");
    }
    fprintf(junk, "quality = %d\n\n", quality);
  }
  fclose(junk);
  */

/*
 * start compressor
 */
  jpeg_start_compress(&cinfo, TRUE);

/*
 * Allocate buffer for one scan line
 */

  row_stride = image_width * 3;	/* JSAMPLEs per row in image_buffer */
  buffer = (*cinfo.mem->alloc_sarray)
		((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);

/*
 * Set up pointers for red, green and blue values.  I think these are [0,1].
 */

  pr_red = mxGetPr(prhs[1]);
  pr_green = mxGetPr(prhs[2]);
  pr_blue = mxGetPr(prhs[3]);


/*
 * Now, loop thru each of the scanlines. For each, copy the image
 * data from the buffer, convert to double, rescale from
 * [0 255] to [0 1] and store in the RGB matrices.
 * This comment (rescale) surprises me -- BW
 */

  while (cinfo.next_scanline < cinfo.image_height) {
     for (i=0;i<cinfo.image_width;i++) {
       j=(i)*cinfo.image_height+cinfo.next_scanline;
       buffer[0][i*3+0] = (pr_red[j])*255;
       buffer[0][i*3+1] = (pr_green[j])*255;
       buffer[0][i*3+2] = (pr_blue[j])*255;
     }
     jpeg_write_scanlines(&cinfo, buffer,1);
  }

/*
 * Clean up
 */

  jpeg_finish_compress(&cinfo);
  fclose(outfile);
  jpeg_destroy_compress(&cinfo);

  return;		
}

