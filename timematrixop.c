#define _GNU_SOURCE
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <sched.h>
#include <time.h>
#include <errno.h>

#include <sys/types.h>
#include <unistd.h>

#include <sys/mman.h>
#include <sys/io.h>

int ossetup(void)
{
    int ret;
    cpu_set_t set;
    struct sched_param sched_param;
    int max_prio = sched_get_priority_max (SCHED_FIFO);
    if (-1 == max_prio) {
        perror("sched_get_priority_max failed");
        ret = -1;
    } else {
        sched_param.sched_priority = max_prio;
        ret = sched_setscheduler(   getpid(),
                                    SCHED_FIFO,
                                    &sched_param);
        if (-1 == ret) {
            perror("sched_setscheduler failed");
        } else {
            /* pin to single CPU */
            CPU_ZERO(&set);
            CPU_SET(0, &set);
            ret = sched_setaffinity(getpid(),
                                    CPU_SETSIZE,
                                    &set);
            if (-1 == ret) {
                perror("sched_setaffinity failed");
            } else {
                ret = mlockall(MCL_CURRENT | MCL_FUTURE);
                if (0 != ret) {
                    perror("mlockall failed");
                } else {
                    ret = iopl(3);
                    if (-1 == ret) {
                        perror("iopl(3) failed");
                    }
                }
            }
        }
    }
    return ret;
}

/*
    Inline assembly taken from:
        http://kernelx.weebly.com/interrupts.html
*/
#define disable_interrupts() do{ asm volatile ("cli"); }while(0)

#define enable_interrupts() do{ asm volatile ("sti"); }while(0)

static int inline clock_gettime_ns (unsigned long long  *time_ns_p)
{
    int ret;
    unsigned long long time_ns;
    struct timespec timespec;
    ret = clock_gettime (   CLOCK_MONOTONIC,
                            &timespec);
    if (0 == ret) {
        time_ns = timespec.tv_sec * 1000000000 + timespec.tv_nsec;
        *time_ns_p = time_ns;
    }
    return ret;
}

/*
    Inline assembly taken from:
        http://cholla.mmto.org/computers/gcc_inline.html
    stamp expected to be "unsigned long long"
*/
#define gettsc(stamp)   do{ \
                            unsigned hi, lo; \
                            asm volatile("rdtsc"  : "=a"(lo), "=d"(hi)); \
                            stamp = hi; \
                            stamp = (stamp << 32) | lo;\
                        }while(0)

int calibrate_tsc(  unsigned long long  **stamp_diff_pp,
                    unsigned long long  **time_diff_pp)
{
    int ret, i;
    unsigned long long start_stamp, end_stamp;
    unsigned long long start_timens, end_timens;
    unsigned long long  *stamp_diff_p;
    unsigned long long  *time_diff_p;
    stamp_diff_p = malloc (1000 * sizeof(unsigned long long));
    if (NULL == stamp_diff_p) {
        fprintf(stderr, "malloc(%lu) failed\n",
                (1000 * sizeof(unsigned long long)));
        ret = -1;
    } else {
        time_diff_p = malloc (1000 * sizeof(unsigned long long));
        if (NULL == time_diff_p) {
            fprintf(stderr, "malloc(%lu) failed\n",
                    (1000 * sizeof(unsigned long long)));
            ret = -1;
        } else {
            for (i=0; i<1000; i++) {
                gettsc(start_stamp); 
                ret = clock_gettime_ns (&start_timens);
                if (0 != ret) {
                    perror("failed to get calibration start time");
                    ret = -1;
                } else {
                    ret = usleep(1000);
                    if (0 != ret) {
                        perror("usleep failed");
                    } else {
                        gettsc(end_stamp); 
                        ret = clock_gettime_ns (&end_timens);
                        if (0 != ret) {
                            perror("failed to get calibration end time");
                            ret = -1;
                        } else {
                            stamp_diff_p[i] = end_stamp - start_stamp;
                            time_diff_p[i] = end_timens - start_timens;
                        }
                    }
                }
            }
            if (0 == ret) {
                *stamp_diff_pp = stamp_diff_p;
                *time_diff_pp = time_diff_p;
            } else {
                free(time_diff_p);
            }
        }
        if (0 != ret) {
            free(stamp_diff_p);
        }
    }
    return ret;
}

/*
    Allocate memory and populate
        NxN maxtrix, A
        N-vector, x
        N-vector, y
    for Ax = y
*/
int allocsystemmem (int                 N,
                    double              **A_pp,
                    double              **x_pp,
                    double              **y_pp)
{
    int ret;
    double *A_p, *x_p, *y_p;
    A_p = (double*)malloc(N*N*sizeof(double));
    if (NULL == A_p) {
        fprintf (stderr, "malloc(%lu) failed\n", N*N*sizeof(double));
        ret = -1;
    } else {
        x_p = (double*)malloc(N*sizeof(double));
        if (NULL == x_p) {
            fprintf (stderr, "malloc(%lu) failed\n", N*sizeof(double));
            ret = -1;
        } else {
            y_p = (double*)malloc(N*sizeof(double));
            if (NULL == y_p) {
                fprintf (stderr, "malloc(%lu) failed\n", N*sizeof(double));
                ret = -1;
            } else {
                *A_pp = A_p;
                *x_pp = x_p;
                *y_pp = y_p;
                ret = 0;
            }
            if (0 != ret) {
                free(x_p);
            }
        }
        if (0 != ret) {
            free(A_p);
        }
    }
    return ret;
}

void populatesystem(int     N,
                    double  *A_p,
                    double  *x_p)
{
    int i;
    for (i=0; i<(N*N); i++) {
        A_p[i] = ((double)rand())/((double)RAND_MAX);
    }
    for (i=0; i<N; i++) {
        x_p[i] = ((double)rand())/((double)RAND_MAX);
    }
}

unsigned long long timeoperation (  int     N,
                                    double  *A_p,
                                    double  *x_p,
                                    double  *y_p)
{
    int y_i, A_c;
    unsigned long long start, stop;
    disable_interrupts();
    gettsc(start);
    for (y_i=0; y_i<N; y_i++) {
        y_p[y_i] = 0.0;
        for (A_c=0; A_c<N; A_c++) {
            y_p[y_i] = y_p[y_i] + A_p[y_i*N + A_c] * x_p[A_c];
        }
    }
    gettsc(stop);
    enable_interrupts();
    return (stop - start);
}

int main (int argc, char**argv)
{
    int ret;
    long int N;
    unsigned long long *stamp_diff_p;
    unsigned long long *time_diff_p;
    double  *A_p;
    double  *x_p;
    double  *y_p;
    unsigned long long op_stampdiff;
    int i;
    if (argc < 2) {
        fprintf (stderr, "Usage: %s N\n", argv[0]);
        ret = -1;
    } else {
        errno = 0;
        N = strtol (argv[1], NULL, 0);
        if (0 != errno) {
            perror("strtol failed");
            ret = -1;
        } else {
            ret = ossetup();
            if (0 != ret) {
                fprintf(stderr, "ossetup failed\n");
            } else {
                ret = calibrate_tsc (   &stamp_diff_p,
                                        &time_diff_p);
                if (0 != ret) {
                    fprintf(stderr, "calibrate_tsc failed\n");
                } else {
                    ret = allocsystemmem (  N,
                                            &A_p,
                                            &x_p,
                                            &y_p);
                    if (0 != ret) {
                        fprintf(stderr, "allocsystemmem failed\n");
                    } else {
                        for (i=0;i<1000;i++) {
                            populatesystem( N,
                                            A_p,
                                            x_p);
                            op_stampdiff = timeoperation (  N,
                                                            A_p,
                                                            x_p,
                                                            y_p);
                            printf ("%llu, %llu, %llu\n",
                                        time_diff_p[i],
                                        stamp_diff_p[i],
                                        op_stampdiff);
                        }
                        free (A_p);
                        free (x_p);
                        free (y_p);
                    }
                }
                free (stamp_diff_p);
                free (time_diff_p);
            }
        }
    }
    return ret;
}

